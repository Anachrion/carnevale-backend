class RemoveCostAndFactionFromCardReferences < ActiveRecord::Migration[8.1]
  def change
    remove_column :card_references, :cost, :integer, default: 0, null: false
    remove_column :card_references, :faction, :string, null: false
  end
end
