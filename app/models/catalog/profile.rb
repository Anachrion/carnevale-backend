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

module Catalog
  class Profile < ApplicationRecord
    include HasFaction
    include StringListColumns

    has_many :card_references, -> { order(:identifier) }, class_name: "Catalog::CardReference"

    has_many :illustrations, -> { order(:number) }, class_name: "Catalog::Illustration"

    has_many :profile_weapons, -> { order(:position) }, class_name: "Catalog::ProfileWeapon"
    has_many :weapons, through: :profile_weapons

    has_many :profile_special_rules, -> { order(:position) }, class_name: "Catalog::ProfileSpecialRule"
    has_many :special_rules, through: :profile_special_rules

    has_many :profile_spell_pools, -> { order(:position) }, class_name: "Catalog::ProfileSpellPool", dependent: :destroy
    has_many :profile_granted_spells, -> { order(:position) }, class_name: "Catalog::ProfileGrantedSpell", dependent: :destroy

    # The models this profile automatically brings into a gang (CARNEVALEB-23) — the Emissary of
    # Mother Hydra's Tentacles. `companions` is the profiles themselves; `profile_companions` carries
    # the per-companion base/upgraded counts CompanionSyncService reads.
    has_many :profile_companions, class_name: "Catalog::ProfileCompanion", dependent: :destroy
    has_many :companions, through: :profile_companions, source: :companion_profile

    # A conditional flex Leader (La Signora) demotes only alongside this specific partner (Il Capitano)
    # rather than any Leader. Nil for hard Leaders and for the "demotes alongside any Leader" flex
    # Leaders (The Duke, Prince of Thieves, Sopracomito).
    belongs_to :flexible_leader_with, class_name: "Catalog::Profile", optional: true

    # Recompute the cached selection validity of every gang that hired this profile. Its ducats,
    # keywords and spell-affecting abilities feed ListValidationService, but a backoffice edit here
    # touches none of those gangs' own rows — so without this their cached selection_valid /
    # selection_errors stay stale (a gang that just went over budget still reads as valid) until the
    # owner next touches the list. Called after a backoffice profile save and a catalog import (B-24).
    def refresh_dependent_list_validity!
      entries = Gang::Entry.where(entry_type: "Catalog::CardReference", entry_id: card_references.select(:id))
      # `WHERE id IN (...)` already returns each list once (id is the PK); no DISTINCT needed — and
      # DISTINCT would fail anyway, since lists carry a json column Postgres can't dedupe on.
      Gang::List.where(id: entries.select(:list_id)).find_each(&:refresh_selection_validity)
    end

    # The stats printed on the card. Everything here is a small non-negative integer, and the
    # backoffice editor is now a way to get bad values into the catalog, so they are checked.
    STATS = %i[
      ducats movement attack dexterity protection mind
      action_points will_points command_points life_points size
    ].freeze

    validates :name, presence: true
    validates :faction, presence: true
    validates(*STATS, numericality: { only_integer: true, greater_than_or_equal_to: 0 })
    validates_string_list :abilities, :keywords
    # Keywords stay free-form (Discipline (…), Leader); only abilities are held to the glossary.
    validates_ability_glossary :abilities, category: "character"

    # Whether this profile can know spells at all — i.e. has at least one spell pool. Standard
    # mages get their one pool from the one-time backfill (CARNEVALEB-47); Apprentice Doctor's is
    # `mentor_derived` (present regardless of whether a mentor has been chosen yet).
    def mage?
      profile_spell_pools.any?
    end

    # Summary total across every pool's slot_count — informational only (the catalog browse
    # endpoint), not used to enforce anything: real enforcement is per-pool, in
    # ListValidationService. An `unlimited` pool contributes 0 here since it has no fixed slot count.
    def spell_slots
      profile_spell_pools.sum(&:slot_count)
    end

    # The union of every pool's eligible discipline slugs — informational only, same caveat as
    # spell_slots. A `mentor_derived` pool contributes nothing here since it has no static list.
    def disciplines
      profile_spell_pools.flat_map(&:disciplines).uniq
    end

    # Replaces this profile's spell pools wholesale. `pools_data` is an array of hashes shaped like
    # { of:, slot_count:, unlimited:, grants_cantrip:, resets_each_round:, mentor_derived:,
    # special_rule_id:, disciplines: [...] }, in the order they should print/apply. A nil array means
    # the caller said nothing about pools (the live card preview, for one), so the current set stands.
    #
    # Pools are owned, ordered child records (unlike weapons/special rules, which are join rows to a
    # shared catalog) — replaced the same way illustrations are: destroy and recreate, rather than
    # diffed in place, since a rework this infrequent doesn't need to preserve individual pool ids.
    def replace_spell_pools!(pools_data)
      return if pools_data.nil?

      transaction do
        profile_spell_pools.destroy_all
        pools_data.each_with_index do |data, index|
          pool = profile_spell_pools.create!(data.except(:disciplines).merge(position: index + 1))
          Array(data[:disciplines]).each { |discipline| pool.profile_spell_pool_disciplines.create!(discipline: discipline) }
        end
      end
    end

    # Same idea for granted spells: { spell_id:, unique_spell_name:, unique_spell_cost:,
    # unique_spell_difficulty:, unique_spell_description:, grant_kind:, consumes_slot:,
    # resets_each_round:, special_rule_id: }.
    def replace_granted_spells!(grants_data)
      return if grants_data.nil?

      transaction do
        profile_granted_spells.destroy_all
        grants_data.each_with_index do |data, index|
          profile_granted_spells.create!(data.merge(position: index + 1))
        end
      end
    end

    # Weapons and special rules are shared records — one "Stiletto" row, referenced by every
    # profile that carries it — so a profile owns only its *claim* on them, held in the join rows
    # along with the order the card prints them in. Replacing the list therefore rewrites those
    # join rows; the weapon itself is never touched, and no other profile is affected.
    #
    # A nil list means the form said nothing about them (Grover's card fetch, for one), so the
    # current list stands.
    def replace_weapons!(ids)
      replace_join!(profile_weapons, :weapon_id, ids)
    end

    def replace_special_rules!(ids)
      replace_join!(profile_special_rules, :special_rule_id, ids)
    end

    # Draw these instead of what the database holds, without writing anything — the editor's live
    # preview renders a card that has not been saved (and may never be).
    def preview_weapons(ids)
      preview_association(:weapons, Catalog::Weapon, ids)
    end

    def preview_special_rules(ids)
      preview_association(:special_rules, Catalog::SpecialRule, ids)
    end

    private

    def replace_join!(collection, foreign_key, ids)
      return if ids.nil?

      transaction do
        collection.destroy_all
        ids.each_with_index { |id, index| collection.create!(foreign_key => id, :position => index + 1) }
      end
    end

    # Ordered by the ids as given: the list's order *is* the print order.
    def preview_association(name, klass, ids)
      return if ids.nil?

      by_id = klass.where(id: ids).index_by(&:id)
      association(name).target = ids.filter_map { |id| by_id[id] }
      association(name).loaded!
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                           :bigint           not null, primary key
#  abilities                    :json             not null
#  action_points                :integer          default(0), not null
#  attack                       :integer          default(0), not null
#  command_points               :integer          default(0), not null
#  companion_upgrade_ducats     :integer          default(0), not null
#  dexterity                    :integer          default(0), not null
#  distinct_discipline_per_copy :boolean          default(FALSE), not null
#  ducats                       :integer          default(0), not null
#  faction                      :string           not null
#  flexible_leader              :boolean          default(FALSE), not null
#  keywords                     :json             not null
#  life_points                  :integer          default(0), not null
#  mind                         :integer          default(0), not null
#  movement                     :integer          default(0), not null
#  name                         :string           default(""), not null
#  protection                   :integer          default(0), not null
#  recruitable                  :boolean          default(TRUE), not null
#  size                         :integer          default(0), not null
#  version                      :string           default("2.2.0"), not null
#  will_points                  :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  flexible_leader_with_id      :bigint
#
# Indexes
#
#  index_profiles_on_flexible_leader_with_id  (flexible_leader_with_id)
#
# Foreign Keys
#
#  fk_rails_...  (flexible_leader_with_id => profiles.id)
#
