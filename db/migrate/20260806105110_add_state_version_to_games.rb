class AddStateVersionToGames < ActiveRecord::Migration[8.1]
  # Monotonic counter stamped onto every serialized game, so a client can tell a newer snapshot from
  # an older one and drop the stale one (A-3). `updated_at` can't serve: almost nothing a broadcast
  # reports lives on this row — turn cursors, scores and `finished` are on game_players, agenda
  # history on agenda_events, the gang on lists — so it stays unchanged across most broadcasts.
  #
  # Existing games start at 0 and are pushed forward by their next broadcast; nothing needs
  # backfilling, since only the ordering between two snapshots of the *same* game matters.
  def change
    add_column :games, :state_version, :integer, default: 0, null: false
  end
end
