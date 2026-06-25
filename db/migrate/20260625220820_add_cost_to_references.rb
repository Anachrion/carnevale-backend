class AddCostToReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :references, :cost, :integer, null: false, default: 0
  end
end
