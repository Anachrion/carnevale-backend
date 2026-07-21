class AddTokensToEntryStates < ActiveRecord::Migration[8.1]
  # Player-attached tokens: a free-form marker (colour + optional label, optionally toggleable) the
  # player sticks on a model to track an in-game effect a rule granted (CARNEVALEB-16). Stored as a
  # JSON array alongside the fixed `counters`/`spell_casts`; default [] backfills existing states.
  def change
    add_column :entry_states, :tokens, :json, null: false, default: []
  end
end
