class CreateEquipment < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.string :name
      t.text :description
      t.integer :cost

      t.timestamps
    end
  end
end
