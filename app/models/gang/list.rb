# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Gang
  class List < ApplicationRecord
    include HasFaction

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

      costs = Hash.new(0)
      model.each { |list_id, sum| costs[list_id] += sum }
      equipment.each { |list_id, sum| costs[list_id] += sum }
      costs
    end

    # Deep-copies this list (and its entries) into a new list owned by `owner`, so the copy stays
    # unaffected by any future edits to this one. Used to freeze a player's gang the moment they
    # select it for a game, so a later battle report always reflects what was actually played.
    def snapshot_for(owner)
      snapshot = List.defer_validation do
        List.transaction do
          List.create!(owner: owner, name: name, faction: faction, points: points, source_list_id: id).tap do |copy|
            list_entries.includes(:entry_spells).each do |entry|
              copied = copy.list_entries.create!(
                entry_type: entry.entry_type, entry_id: entry.entry_id,
                position: entry.position, spell_discipline: entry.spell_discipline
              )
              entry.entry_spells.each { |es| copied.entry_spells.create!(spell_id: es.spell_id) }
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
