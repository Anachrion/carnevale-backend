class CreateLists < ActiveRecord::Migration[8.1]
  def change
    create_table :lists do |t|
      t.string :name
      t.integer :points, default: 100, null: false
      t.string :faction

      t.timestamps
    end
  end
end
