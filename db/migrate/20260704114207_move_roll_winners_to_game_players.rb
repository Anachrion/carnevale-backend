class MoveRollWinnersToGamePlayers < ActiveRecord::Migration[8.1]
  def up
    add_column :game_players, :won_role_roll, :boolean, null: false, default: false
    add_column :game_players, :won_deployment_roll, :boolean, null: false, default: false

    execute <<~SQL
      UPDATE game_players SET won_role_roll = true
      FROM games WHERE games.role_roll_winner_id = game_players.id
    SQL
    execute <<~SQL
      UPDATE game_players SET won_deployment_roll = true
      FROM games WHERE games.deployment_roll_winner_id = game_players.id
    SQL

    add_index :game_players, :game_id, unique: true, where: "won_role_roll",
      name: "index_game_players_on_game_id_where_won_role_roll"
    add_index :game_players, :game_id, unique: true, where: "won_deployment_roll",
      name: "index_game_players_on_game_id_where_won_deployment_roll"

    remove_column :games, :role_roll_winner_id
    remove_column :games, :deployment_roll_winner_id
  end

  def down
    add_column :games, :role_roll_winner_id, :bigint
    add_column :games, :deployment_roll_winner_id, :bigint
    add_index :games, :role_roll_winner_id
    add_index :games, :deployment_roll_winner_id
    add_foreign_key :games, :game_players, column: :role_roll_winner_id
    add_foreign_key :games, :game_players, column: :deployment_roll_winner_id

    execute <<~SQL
      UPDATE games SET role_roll_winner_id = game_players.id
      FROM game_players WHERE game_players.game_id = games.id AND game_players.won_role_roll = true
    SQL
    execute <<~SQL
      UPDATE games SET deployment_roll_winner_id = game_players.id
      FROM game_players WHERE game_players.game_id = games.id AND game_players.won_deployment_roll = true
    SQL

    remove_index :game_players, name: "index_game_players_on_game_id_where_won_role_roll"
    remove_index :game_players, name: "index_game_players_on_game_id_where_won_deployment_roll"
    remove_column :game_players, :won_role_roll
    remove_column :game_players, :won_deployment_roll
  end
end
