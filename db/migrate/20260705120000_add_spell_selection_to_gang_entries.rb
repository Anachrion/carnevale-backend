class AddSpellSelectionToGangEntries < ActiveRecord::Migration[8.1]
  def change
    # The Discipline a Mage model has committed to for the game. All of its known spells must
    # come from this Discipline (rulebook p24). Null for non-Mage entries and Mages with no
    # Discipline picked yet.
    add_column :list_entries, :spell_discipline, :string

    create_table :entry_spells do |t|
      t.references :list_entry, null: false, foreign_key: { to_table: :list_entries }
      t.references :spell, null: false, foreign_key: true

      t.timestamps
    end

    add_index :entry_spells, %i[list_entry_id spell_id], unique: true
  end
end
