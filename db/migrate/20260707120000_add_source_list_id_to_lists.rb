class AddSourceListIdToLists < ActiveRecord::Migration[8.1]
  # A gang snapshot (the frozen copy created when a player selects a list for a game) records the
  # id of the source list it was copied from, so the client can tell which of a player's lists is
  # currently selected. Nullable: source lists themselves have no source, and a source list may be
  # deleted later without invalidating the snapshot.
  def change
    add_column :lists, :source_list_id, :bigint, null: true
    add_index :lists, :source_list_id
  end
end
