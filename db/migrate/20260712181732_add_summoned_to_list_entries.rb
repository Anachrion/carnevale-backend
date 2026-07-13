class AddSummonedToListEntries < ActiveRecord::Migration[8.1]
  # Models conjured onto the board mid-game by a special rule, rather than hired during gang
  # building. They are flagged so they can be kept out of the gang-*building* rules — the ducat
  # limit, faction consistency, and the unique/Leader/ratio checks — none of which has anything to
  # say about a model that appears in the middle of a battle. See ListValidationService and
  # Gang::List#total_cost, both of which skip them.
  def change
    add_column :list_entries, :summoned, :boolean, default: false, null: false
  end
end
