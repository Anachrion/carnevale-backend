class CreateProfileSpellPoolDisciplines < ActiveRecord::Migration[8.1]
  def change
    # The eligible-disciplines set for a pool. Plural rows so a single pool can list more than the
    # `of` disciplines that actually apply at once (Doctor of the Firmament: 3 eligible, 2 apply;
    # Seamstress: 2 eligible per pool, 1 applies).
    create_table :profile_spell_pool_disciplines do |t|
      t.references :pool, null: false, foreign_key: { to_table: :profile_spell_pools }
      t.string :discipline, null: false

      t.timestamps
    end

    add_index :profile_spell_pool_disciplines, %i[pool_id discipline], unique: true, name: "index_pool_disciplines_on_pool_and_discipline"
  end
end
