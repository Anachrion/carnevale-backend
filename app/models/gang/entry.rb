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

    delegate :cost, to: :entry

    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :position, uniqueness: { scope: :list_id }
    # entry_type is client-supplied on create (POST /list_entries); without this, any AR class name
    # constantizes and saves, then blows up every later read that calls .cost/.name on it.
    validates :entry_type, inclusion: { in: %w[Catalog::CardReference Catalog::Equipment] }
    # A committed Discipline must be a real one (nil until a mage picks spells). Without this a
    # mis-cased or bogus value ("Blood Rites" instead of "blood_rites") saved silently and only
    # surfaced later as a confusing "cannot use the Blood rites Discipline" error (B-28).
    validates :spell_discipline, inclusion: { in: Catalog::Spell::DISCIPLINES }, allow_nil: true

    # The Catalog::Profile behind this entry, or nil for non-model entries (e.g. Equipment).
    def profile
      entry.profile if entry.is_a?(Catalog::CardReference)
    end

    private

    def selection_validity_list
      list
    end
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id               :bigint           not null, primary key
#  entry_type       :string           not null
#  position         :integer          not null
#  spell_discipline :string
#  summoned         :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entry_id         :bigint           not null
#  list_id          :bigint           not null
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#
