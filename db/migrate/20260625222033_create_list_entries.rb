class CreateListEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :list_entries do |t|
      t.references :list, null: false, foreign_key: true
      t.references :reference, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :list_entries, [ :list_id, :position ], unique: true
    add_index :list_entries, [ :list_id, :reference_id ], unique: true
  end
end
