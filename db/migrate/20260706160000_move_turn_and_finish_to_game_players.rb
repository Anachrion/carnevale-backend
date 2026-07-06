class MoveTurnAndFinishToGamePlayers < ActiveRecord::Migration[8.1]
  # The turn counter becomes a per-player rewindable cursor, and each player gets their own
  # "finished" (ended the game) flag — so one player can correct a past-turn score or end the game
  # without moving the other's view. Game-level completion is derived from both players' `finished`.
  def up
    add_column :game_players, :current_turn, :integer, null: false, default: 1
    add_column :game_players, :finished, :boolean, null: false, default: false

    execute <<~SQL.squish
      UPDATE game_players
      SET current_turn = games.current_turn
      FROM games
      WHERE game_players.game_id = games.id
    SQL

    remove_column :games, :current_turn
  end

  def down
    add_column :games, :current_turn, :integer, null: false, default: 1

    execute <<~SQL.squish
      UPDATE games
      SET current_turn = sub.max_turn
      FROM (SELECT game_id, MAX(current_turn) AS max_turn FROM game_players GROUP BY game_id) sub
      WHERE games.id = sub.game_id
    SQL

    remove_column :game_players, :finished
    remove_column :game_players, :current_turn
  end
end
