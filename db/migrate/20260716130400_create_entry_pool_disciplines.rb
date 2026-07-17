class CreateEntryPoolDisciplines < ActiveRecord::Migration[8.1]
  def change
    # Replaces list_entries.spell_discipline (a single column) — a Gang::Entry now commits a
    # discipline per pool it has, so a model with more than one pool (Seamstress, Doctor of the
    # Firmament) can have more than one committed discipline, and a pool with `of > 1` can have more
    # than one row here for the same pool.
    create_table :entry_pool_disciplines do |t|
      t.references :list_entry, null: false, foreign_key: true
      # Cascades on delete for the same reason as entry_spells.pool_id: reconfiguring a profile's
      # pools invalidates any discipline already committed against the pool being replaced.
      t.references :pool, null: false, foreign_key: { to_table: :profile_spell_pools, on_delete: :cascade }
      t.string :discipline, null: false

      t.timestamps
    end

    add_index :entry_pool_disciplines, %i[list_entry_id pool_id discipline], unique: true, name: "index_entry_pool_disciplines_uniqueness"
  end
end
