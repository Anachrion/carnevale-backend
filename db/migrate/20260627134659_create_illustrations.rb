class CreateIllustrations < ActiveRecord::Migration[8.1]
  def change
    create_table :illustrations do |t|
      t.references :profile,  null: false, foreign_key: true
      t.integer    :number,   null: false, default: 1
      t.string     :path,     null: false
      t.integer    :offset_x, null: false, default: 0
      t.integer    :offset_y, null: false, default: 0
      t.integer    :zoom,     null: false, default: 100
      t.boolean    :flipped,  null: false, default: false

      t.timestamps
    end

    add_index :illustrations, [ :profile_id, :number ], unique: true
  end
end
