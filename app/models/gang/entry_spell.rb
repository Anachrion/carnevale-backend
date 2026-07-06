module Gang
  class EntrySpell < ApplicationRecord
    include RefreshesListSelectionValidity

    self.table_name = "entry_spells"

    belongs_to :list_entry, class_name: "Gang::Entry"
    belongs_to :spell, class_name: "Catalog::Spell"

    validates :spell_id, uniqueness: { scope: :list_entry_id }

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
#  spell_id      :bigint           not null
#
# Indexes
#
#  index_entry_spells_on_list_entry_id               (list_entry_id)
#  index_entry_spells_on_list_entry_id_and_spell_id  (list_entry_id,spell_id) UNIQUE
#  index_entry_spells_on_spell_id                    (spell_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#  fk_rails_...  (spell_id => spells.id)
#
