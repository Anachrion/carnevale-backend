class RemoveDeploymentZoneFromGamePlayers < ActiveRecord::Migration[8.1]
  def change
    remove_column :game_players, :deployment_zone, :string
  end
end
