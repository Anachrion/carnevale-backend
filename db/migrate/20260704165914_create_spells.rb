class CreateSpells < ActiveRecord::Migration[8.1]
  def change
    create_table :spells do |t|
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.integer :cost, null: false
      t.integer :difficulty, null: false
      t.string :discipline, null: false
      t.boolean :cantrip, null: false, default: false

      t.timestamps
    end
  end
end
