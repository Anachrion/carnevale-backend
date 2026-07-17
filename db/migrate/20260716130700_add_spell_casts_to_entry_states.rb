class AddSpellCastsToEntryStates < ActiveRecord::Migration[8.1]
  def change
    # Tracks which known/granted spells this model has cast, keyed by spell identity, valued by the
    # round (current_turn, see Encounter::Player) it was cast on — the exact same "store the turn,
    # not a boolean" shape `counters["activated_on_turn"]` already uses, so a fresh round reads
    # everything as unused with no bulk-reset write, and rewinding a round restores that round's
    # state. A pool/grant with resets_each_round: false (Adventuring Noble) instead treats any stored
    # entry as permanently exhausted for the rest of the game.
    add_column :entry_states, :spell_casts, :json, default: {}, null: false
  end
end
