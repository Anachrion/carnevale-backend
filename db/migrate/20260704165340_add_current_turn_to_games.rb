class AddCurrentTurnToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :current_turn, :integer, null: false, default: 1
  end
end
