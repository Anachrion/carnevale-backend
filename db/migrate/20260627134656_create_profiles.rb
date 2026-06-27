class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string  :name,           null: false, default: ""
      t.string  :faction,        null: false, default: ""
      t.string  :version,        null: false, default: "2.2.0"
      t.integer :action_points,  null: false, default: 0
      t.integer :life_points,    null: false, default: 0
      t.integer :will_points,    null: false, default: 0
      t.integer :command_points, null: false, default: 0
      t.integer :size,           null: false, default: 0
      t.integer :ducats,         null: false, default: 0
      t.integer :movement,       null: false, default: 0
      t.integer :dexterity,      null: false, default: 0
      t.integer :attack,         null: false, default: 0
      t.integer :protection,     null: false, default: 0
      t.integer :mind,           null: false, default: 0
      t.json    :keywords,       null: false, default: []
      t.json    :abilities,      null: false, default: []

      t.timestamps
    end
  end
end
