class AddCompanionFieldsToListEntries < ActiveRecord::Migration[8.1]
  # CARNEVALEB-23: a companion entry (a Tentacle) links back to the model that brought it
  # (`companion_of_entry_id`, a self-reference). Removing that parent cascades the companions away
  # with it (ON DELETE CASCADE) — they can't be hired or removed on their own.
  #
  # `upgrade_selected` lives on the *parent* entry (the Emissary): whether the player has bought the
  # optional +12-Ducat upgrade that doubles its companions.
  def change
    add_column :list_entries, :upgrade_selected, :boolean, null: false, default: false
    add_reference :list_entries, :companion_of_entry, null: true,
                  foreign_key: { to_table: :list_entries, on_delete: :cascade }
  end
end
