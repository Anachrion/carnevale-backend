module Gang
  class EntrySpell < ApplicationRecord
    self.table_name = "entry_spells"

    belongs_to :list_entry, class_name: "Gang::Entry"
    belongs_to :spell, class_name: "Catalog::Spell"

    validates :spell_id, uniqueness: { scope: :list_entry_id }

    after_commit :refresh_list_selection_validity, on: %i[create update destroy]

    private

    def refresh_list_selection_validity
      list_entry.list.refresh_selection_validity
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
