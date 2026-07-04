class CreateEntryStates < ActiveRecord::Migration[8.1]
  def change
    create_table :entry_states do |t|
      t.references :list_entry, null: false, foreign_key: { to_table: :list_entries }, index: { unique: true }
      t.integer :current_life_points, null: false
      t.integer :starting_life_points, null: false
      t.integer :current_will_points, null: false
      t.integer :starting_will_points, null: false
      t.integer :current_command_points, null: false
      t.integer :starting_command_points, null: false
      t.json :counters, default: {}, null: false

      t.timestamps
    end
  end
end
