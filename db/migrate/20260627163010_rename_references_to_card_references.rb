class RenameReferencesToCardReferences < ActiveRecord::Migration[8.1]
  def change
    rename_table :references, :card_references
    rename_column :list_entries, :reference_id, :card_reference_id
  end
end
