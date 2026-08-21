# A player's physical collection: for each catalog profile, how many miniatures they own, how many
# of those are assembled, and how many of those are painted (CARNEVALEB-76).
#
# Per profile rather than per card reference: 63 of the 316 profiles are printed on two cards, but
# those are two illustrations of the same miniature, not two models.
#
# Rows are deleted once all three counts reach zero rather than kept at zero, so the table stays
# proportional to what players actually own instead of holding 316 rows per account.
class CreateCollectionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_items do |t|
      # No standalone index on user_id: the composite unique index below leads with it, so it
      # already serves "this player's whole collection", which is the only way this is read.
      t.references :user, null: false, foreign_key: true, index: false
      t.references :profile, null: false, foreign_key: true
      t.integer :owned, null: false, default: 0
      t.integer :built, null: false, default: 0
      t.integer :painted, null: false, default: 0

      t.timestamps
    end

    add_index :collection_items, %i[user_id profile_id], unique: true

    # The counts nest, and the model normalises them before every save. This is the backstop for
    # any path that ever forgets to: a painted miniature is necessarily assembled, and an assembled
    # one is necessarily owned.
    add_check_constraint :collection_items,
                         "painted >= 0 AND built >= painted AND owned >= built",
                         name: "collection_items_counts_nest"
  end
end
