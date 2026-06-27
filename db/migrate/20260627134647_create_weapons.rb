class CreateWeapons < ActiveRecord::Migration[8.1]
  def change
    create_table :weapons do |t|
      t.string  :name,        null: false
      t.integer :range,       null: false, default: 0
      t.integer :evasion,     null: false, default: 0
      t.integer :damage,      null: false, default: 0
      t.integer :penetration, null: false, default: 0
      t.json    :abilities,   null: false, default: []

      t.timestamps
    end
  end
end
