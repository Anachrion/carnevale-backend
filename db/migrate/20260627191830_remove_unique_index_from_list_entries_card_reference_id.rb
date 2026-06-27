class RemoveUniqueIndexFromListEntriesCardReferenceId < ActiveRecord::Migration[8.1]
  def change
    remove_index :list_entries, [:list_id, :card_reference_id], unique: true, name: "index_list_entries_on_list_id_and_card_reference_id"
  end
end
