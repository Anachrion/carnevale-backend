# The two switches behind the Collection feature (CARNEVALEB-76), both on the account rather than
# in the app's local settings: someone who tracks a collection does it the same way on every device
# they own, so both have to follow them from phone to tablet to web — as the collection itself does.
#
#   collection_enabled — the feature is live: marks in the catalogue and the hire list, the summary
#                        button in the gang builder. Off by default; it introduces itself on first
#                        visit and asks.
#   collection_visible — the feature is offered at all: the entry on the home screen and in the
#                        menu. On by default. Turning it off hides everything, including the marks,
#                        while remembering that the feature had been switched on — so turning it
#                        back on returns to the collection rather than to the introduction.
class AddCollectionSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :collection_enabled, :boolean, default: false, null: false
    add_column :users, :collection_visible, :boolean, default: true, null: false
  end
end
