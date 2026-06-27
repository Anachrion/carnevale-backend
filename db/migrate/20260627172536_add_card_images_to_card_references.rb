class AddCardImagesToCardReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :card_references, :card_front, :string
    add_column :card_references, :card_back, :string
  end
end
