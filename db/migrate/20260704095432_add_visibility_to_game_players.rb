class AddVisibilityToGamePlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :game_players, :visibility, :string, null: false, default: "active"
  end
end
