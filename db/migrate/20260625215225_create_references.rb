class CreateReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :references do |t|
      t.string :name
      t.string :identifier, null: false

      t.timestamps
    end

    add_index :references, :identifier, unique: true
  end
end
