class AddPoolToEntrySpells < ActiveRecord::Migration[8.1]
  def change
    # Which pool this known spell was picked from. Nullable for now — backfilled in the next
    # migration, then tightened to NOT NULL once every existing row has a value. Cascades on
    # delete: if a profile's pool structure is later reconfigured (replace_spell_pools! destroys and
    # recreates its pools), any known-spell picks tied to a pool that no longer exists are simply
    # gone, not left pointing at nothing — the model's spells must be re-picked either way.
    add_reference :entry_spells, :pool, null: true,
      foreign_key: { to_table: :profile_spell_pools, on_delete: :cascade }
  end
end
