class AddFactionToReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :references, :faction, :string, null: false, default: nil
  end
end
