class AddRollWinnersToGames < ActiveRecord::Migration[8.1]
  def change
    add_reference :games, :role_roll_winner, null: true, foreign_key: { to_table: :game_players }
    add_reference :games, :deployment_roll_winner, null: true, foreign_key: { to_table: :game_players }
  end
end
