class CreateSpecialRules < ActiveRecord::Migration[8.1]
  def change
    create_table :special_rules do |t|
      t.string  :name,             null: false
      t.text    :description,      null: false, default: ""
      t.string  :spell_name
      t.text    :spell_description
      t.integer :spell_difficulty
      t.integer :spell_cost

      t.timestamps
    end
  end
end
