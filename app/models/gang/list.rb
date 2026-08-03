# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

module Gang
  class List < ApplicationRecord
    include HasFaction
    include IdempotentEntries

    belongs_to :owner, polymorphic: true
    has_many :list_entries, class_name: "Gang::Entry", dependent: :destroy

    validates :name, presence: true
    validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :faction, presence: true

    after_commit :refresh_selection_validity, on: %i[create update]

    # Wrap a bulk edit that touches many entries/spells (replacing a model's whole spell set, or
    # snapshotting a list) so the flurry of child `after_commit` callbacks it fires don't each
    # re-run the full multi-query validation; the caller runs it once at the end instead (B-P2-6).
    def self.defer_validation
      previous = Thread.current[:carnevale_defer_list_validation]
      Thread.current[:carnevale_defer_list_validation] = true
      yield
    ensure
      Thread.current[:carnevale_defer_list_validation] = previous
    end

    def refresh_selection_validity
      return if destroyed?
      return if Thread.current[:carnevale_defer_list_validation]

      result = ListValidationService.call(self)
      # Bump updated_at too: validity can change without any other column moving (e.g. a catalog
      # rebalance via refresh_dependent_list_validity!), so a future `fresh_when @list` would
      # otherwise serve a stale selection_valid/selection_errors (B-29).
      update_columns(selection_valid: result[:success], selection_errors: result[:errors], updated_at: Time.current)
    end

    # Total ducat cost of the list — profile ducats for model entries, the equipment's own cost for
    # gear — computed in SQL so it neither loads every entry nor resolves its profile. The old
    # Ruby-side `list_entries.sum(&:cost)` walked the polymorphic entry -> profile chain per row
    # (the B-P2-2 N+1); two aggregate queries replace that regardless of list size.
    #
    # Summoned models are excluded: they were conjured mid-battle by a special rule, not bought, so
    # charging the gang for them would show it over a limit it never actually exceeded.
    def total_cost
      self.class.total_costs_for([ id ])[id] || 0
    end

    # Total ducat cost for many lists in two grouped queries, keyed by list id — so serializing a
    # batch of lists (e.g. every player's gang across the games index) doesn't run two aggregate
    # queries per list (B-34). Summoned models are free and excluded, matching #total_cost.
    def self.total_costs_for(list_ids)
      ids = Array(list_ids).uniq
      return {} if ids.empty?

      hired = Gang::Entry.where(list_id: ids, summoned: false)
      model = hired
        .where(entry_type: "Catalog::CardReference")
        .joins("INNER JOIN card_references ON card_references.id = list_entries.entry_id")
        .joins("INNER JOIN profiles ON profiles.id = card_references.profile_id")
        .group(:list_id).sum("profiles.ducats")
      equipment = hired
        .where(entry_type: "Catalog::Equipment")
        .joins("INNER JOIN equipment ON equipment.id = list_entries.entry_id")
        .group(:list_id).sum("equipment.cost")
      # The Ducats added by a bought companion upgrade (the Emissary's +12 for a second set of
      # Tentacles) — folded in here so this SQL sum matches Gang::Entry#cost, which adds the same
      # surcharge in Ruby (CARNEVALEB-23). Keep the two in step.
      upgrades = hired
        .where(entry_type: "Catalog::CardReference", upgrade_selected: true)
        .joins("INNER JOIN card_references ON card_references.id = list_entries.entry_id")
        .joins("INNER JOIN profiles ON profiles.id = card_references.profile_id")
        .group(:list_id).sum("profiles.companion_upgrade_ducats")

      costs = Hash.new(0)
      model.each { |list_id, sum| costs[list_id] += sum }
      equipment.each { |list_id, sum| costs[list_id] += sum }
      upgrades.each { |list_id, sum| costs[list_id] += sum }
      costs
    end

    # Deep-copies this list (and its entries) into a new list owned by `owner`, so the copy stays
    # unaffected by any future edits to this one. Used to freeze a player's gang the moment they
    # select it for a game, so a later battle report always reflects what was actually played.
    def snapshot_for(owner)
      snapshot = List.defer_validation do
        List.transaction do
          List.create!(owner: owner, name: name, faction: faction, points: points, source_list_id: id).tap do |copy|
            source_entries = list_entries.includes(:entry_spells, :entry_pool_disciplines).to_a
            copied_by_source_id = {}

            source_entries.each do |entry|
              copied = copy.list_entries.create!(
                entry_type: entry.entry_type, entry_id: entry.entry_id, position: entry.position,
                upgrade_selected: entry.upgrade_selected
              )
              copied_by_source_id[entry.id] = copied
              entry.entry_spells.each { |es| copied.entry_spells.create!(spell_id: es.spell_id, pool_id: es.pool_id) }
              entry.entry_pool_disciplines.each do |epd|
                copied.entry_pool_disciplines.create!(pool_id: epd.pool_id, discipline: epd.discipline)
              end
            end

            # mentored_by_entry_id and companion_of_entry_id both point at another entry in the *same*
            # list (Apprentice Doctor's mentor link; the Emissary → Tentacle link), so they can only
            # be remapped once every copy exists — a second pass, since the target may be created
            # before or after this entry in position order.
            source_entries.each do |entry|
              updates = {}
              updates[:mentored_by_entry_id] = copied_by_source_id[entry.mentored_by_entry_id]&.id if entry.mentored_by_entry_id
              updates[:companion_of_entry_id] = copied_by_source_id[entry.companion_of_entry_id]&.id if entry.companion_of_entry_id
              copied_by_source_id[entry.id].update!(updates) if updates.any?
            end
          end
        end
      end
      snapshot.refresh_selection_validity
      snapshot
    end
  end
end

# == Schema Information
#
# Table name: lists
#
#  id               :bigint           not null, primary key
#  faction          :string           not null
#  name             :string
#  owner_type       :string           not null
#  points           :integer          default(100), not null
#  selection_errors :json             not null
#  selection_valid  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  owner_id         :bigint           not null
#  source_list_id   :bigint
#
# Indexes
#
#  index_lists_on_owner           (owner_type,owner_id)
#  index_lists_on_source_list_id  (source_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_list_id => lists.id) ON DELETE => nullify
#
