class CreateGamePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :game_players do |t|
      t.references :game,  null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.references :list,  null: true,  foreign_key: true
      t.boolean :host,             null: false, default: false
      t.string  :role
      t.string  :deployment_zone
      t.integer :role_roll
      t.integer :deployment_roll
      t.boolean :ready,            null: false, default: false
      t.json    :agenda_ids,       null: false, default: []

      t.timestamps
    end

    add_index :game_players, [:game_id, :user_id], unique: true
  end
end
