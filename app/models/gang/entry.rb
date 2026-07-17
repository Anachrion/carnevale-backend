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
  class Entry < ApplicationRecord
    include RefreshesListSelectionValidity

    self.table_name = "list_entries"

    belongs_to :list, class_name: "Gang::List"
    belongs_to :entry, polymorphic: true
    has_one :entry_state, class_name: "Encounter::EntryState", foreign_key: "list_entry_id", dependent: :destroy
    has_many :entry_spells, class_name: "Gang::EntrySpell", foreign_key: "list_entry_id", dependent: :destroy
    has_many :spells, through: :entry_spells, class_name: "Catalog::Spell"
    has_many :entry_pool_disciplines, class_name: "Gang::EntryPoolDiscipline", foreign_key: "list_entry_id", dependent: :destroy
    # Apprentice Doctor's Apprenticeship: the other model in the same gang she's copying Mage access
    # from. Nullified (not cascaded) if that entry is removed — see the migration.
    belongs_to :mentored_by_entry, class_name: "Gang::Entry", optional: true

    delegate :cost, to: :entry

    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :position, uniqueness: { scope: :list_id }
    # entry_type is client-supplied on create (POST /list_entries); without this, any AR class name
    # constantizes and saves, then blows up every later read that calls .cost/.name on it.
    validates :entry_type, inclusion: { in: %w[Catalog::CardReference Catalog::Equipment] }
    validate :mentor_in_same_list

    # The Catalog::Profile behind this entry, or nil for non-model entries (e.g. Equipment).
    def profile
      entry.profile if entry.is_a?(Catalog::CardReference)
    end

    # This entry's profile's spell pools, each annotated with what *this* model has actually
    # committed to it: which discipline(s) it picked (chosen_disciplines) and which spells it knows
    # from that pool (spells — full Catalog::Spell records, resolved from the already-preloaded
    # entry_spells: :spell association rather than a fresh query per pool). A `mentor_derived`
    # pool's eligible_disciplines/slot_count are resolved from the mentor's own first pool instead
    # of the profile's static data — Apprentice Doctor still makes her own picks
    # (chosen_disciplines/spells stay hers), only the *menu* she picks from is borrowed. `of` is
    # always 1 (plain Mage), regardless of the mentor's own `of` — see the comment below.
    def resolved_pools
      return [] unless profile

      profile.profile_spell_pools.map do |pool|
        mentor_pool = pool.mentor_derived? ? mentored_by_entry&.profile&.profile_spell_pools&.first : nil
        eligible = pool.mentor_derived? ? (mentor_pool&.disciplines || []) : pool.disciplines
        # `unlimited` (Adventuring Noble's Arcane Totem): nothing was ever picked — the model knows
        # every spell of its one eligible Discipline automatically, so chosen_disciplines mirrors
        # eligible_disciplines outright and spells comes straight from the catalog rather than
        # entry_spells (which stays empty; there was never anything to record a pick into).
        chosen = pool.unlimited? ? eligible : entry_pool_disciplines.select { |epd| epd.pool_id == pool.id }.map(&:discipline)
        spells = pool.unlimited? ? Catalog::Spell.where(discipline: chosen, cantrip: false) : entry_spells.select { |es| es.pool_id == pool.id }.map(&:spell)
        {
          pool: pool,
          # Always 1 for a mentor_derived pool, never the mentor's own `of` — Apprenticeship copies
          # the plain Mage ability only ("If choosing Mage, the disciplines available are the same
          # as the mentor"), not whatever special multi-Discipline mechanic that mentor might
          # separately have (Aetheric Gaze's of: 2 is Doctor of the Firmament's own ability, not
          # part of Mage itself — copying Mage from her still means "pick one Discipline").
          of: pool.mentor_derived? ? 1 : pool.of,
          eligible_disciplines: eligible,
          # Apprenticeship copies the Mage ability alone, never Expert Sorcerer — mage_slot_count is
          # the Mage(X)-only portion of the mentor's slot_count (see the profile_spell_pools schema
          # comment), so a mentor with both abilities (Doctor of the Firmament) still only hands the
          # apprentice the Mage-sized slot count, not the combined total.
          slot_count: pool.mentor_derived? ? (mentor_pool&.mage_slot_count || 0) : pool.slot_count,
          chosen_disciplines: chosen,
          spells: spells
        }
      end
    end

    private

    # Apprentice Doctor's Apprenticeship picks a mentor from the same gang only — without this, a
    # buggy or malicious client could point mentored_by_entry_id at another user's list entirely,
    # and #resolved_pools would happily read that stranger's pool data into this model's picker.
    def mentor_in_same_list
      return unless mentored_by_entry && mentored_by_entry.list_id != list_id

      errors.add(:mentored_by_entry, "must belong to the same list")
    end

    def selection_validity_list
      list
    end
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id                   :bigint           not null, primary key
#  entry_type           :string           not null
#  position             :integer          not null
#  spell_discipline     :string
#  summoned             :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  entry_id             :bigint           not null
#  list_id              :bigint           not null
#  mentored_by_entry_id :bigint
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#  index_list_entries_on_mentored_by_entry_id     (mentored_by_entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (mentored_by_entry_id => list_entries.id) ON DELETE => nullify
#
