class AddSourceDigestToCardReferences < ActiveRecord::Migration[8.1]
  def change
    add_column :card_references, :source_digest, :string
  end
end
