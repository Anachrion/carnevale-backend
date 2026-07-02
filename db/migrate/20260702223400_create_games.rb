class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :scenario,  null: false, foreign_key: true
      t.integer    :ducat_limit, null: false
      t.string     :board_size
      t.string     :join_code, null: false
      t.string     :status,    null: false, default: "pending"

      t.timestamps
    end

    add_index :games, :join_code, unique: true
  end
end
