class AddProfileToCardReferences < ActiveRecord::Migration[8.1]
  def change
    add_reference :card_references, :profile, null: true, foreign_key: true
  end
end
