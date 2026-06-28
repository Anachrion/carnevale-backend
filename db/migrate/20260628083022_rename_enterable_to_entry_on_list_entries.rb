class RenameEnterableToEntryOnListEntries < ActiveRecord::Migration[8.1]
  def change
    rename_column :list_entries, :enterable_type, :entry_type
    rename_column :list_entries, :enterable_id, :entry_id
  end
end
