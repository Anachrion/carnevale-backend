class DropDeployingPhaseAndReady < ActiveRecord::Migration[8.1]
  # The in-app deployment step is gone: deployment zones are agreed at the table, so once both
  # players confirm their opening Agenda hand the game goes straight live. Any game currently paused
  # on the old deployment screen is promoted to in_progress here, backfilling the per-model entry
  # states that the ready-handshake used to create, before the now-unused `ready` flag is dropped.
  def up
    Encounter::Game.where(status: "deploying").find_each do |game|
      game.send(:create_entry_states!)
      game.update_columns(status: "in_progress")
    end

    remove_column :game_players, :ready
  end

  def down
    add_column :game_players, :ready, :boolean, default: false, null: false
  end
end
