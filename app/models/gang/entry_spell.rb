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
  class EntrySpell < ApplicationRecord
    include RefreshesListSelectionValidity

    self.table_name = "entry_spells"

    belongs_to :list_entry, class_name: "Gang::Entry"
    belongs_to :spell, class_name: "Catalog::Spell"
    belongs_to :pool, class_name: "Catalog::ProfileSpellPool", optional: true

    validates :spell_id, uniqueness: { scope: :list_entry_id }
    # Enforced here rather than a DB NOT NULL: the column has to stay nullable so a profile's pool
    # structure can be reconfigured (replace_spell_pools! destroys old pools, cascading these rows
    # away) without a window where an in-flight write could violate a stricter constraint.
    validates :pool_id, presence: true

    private

    # Nil-safe because the after_commit refresh also fires on destroy: when an entry_spell is
    # removed as part of tearing down its whole list (e.g. deleting a game and its snapshot), the
    # parent list_entry is already gone by the time this runs, so reaching through it must no-op
    # rather than raise (there's no surviving list left to refresh).
    def selection_validity_list
      list_entry&.list
    end
  end
end

# == Schema Information
#
# Table name: entry_spells
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_entry_id :bigint           not null
#  pool_id       :bigint
#  spell_id      :bigint           not null
#
# Indexes
#
#  index_entry_spells_on_list_entry_id               (list_entry_id)
#  index_entry_spells_on_list_entry_id_and_spell_id  (list_entry_id,spell_id) UNIQUE
#  index_entry_spells_on_pool_id                     (pool_id)
#  index_entry_spells_on_spell_id                    (spell_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#  fk_rails_...  (pool_id => profile_spell_pools.id) ON DELETE => cascade
#  fk_rails_...  (spell_id => spells.id)
#
