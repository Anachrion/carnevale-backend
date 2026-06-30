class AddSelectionValidityToLists < ActiveRecord::Migration[8.1]
  def change
    add_column :lists, :selection_valid, :boolean, default: false, null: false
    add_column :lists, :selection_errors, :json, default: [], null: false
  end
end
