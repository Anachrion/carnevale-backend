class RemoveDiceRollsFromGamePlayers < ActiveRecord::Migration[8.1]
  def change
    remove_column :game_players, :role_roll, :integer
    remove_column :game_players, :deployment_roll, :integer
  end
end
