class AddMentoredByToListEntries < ActiveRecord::Migration[8.1]
  def change
    # Apprentice Doctor's Apprenticeship: which other model in the same gang she's copying Mage
    # access from. Nullable (no mentor chosen yet); nullified rather than cascaded if the mentor
    # entry is removed from the gang, matching the existing lists.source_list_id pattern, so removing
    # her mentor doesn't also delete her.
    add_reference :list_entries, :mentored_by_entry, null: true,
      foreign_key: { to_table: :list_entries, on_delete: :nullify }
  end
end
