class AddIllustrationPathToCardReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :card_references, :illustration_path, :string
  end
end
