# Change history on the catalog (CARNEVALEB-81), stored the way paper_trail expects, with two
# additions:
#
#   card_snapshot    — on Catalog::Profile versions only: the whole card (stats, ordered weapons,
#                      special rules, spell pools, granted spells, companions) as it stood after the
#                      save. A card is versioned as one document rather than row by row because its
#                      join rows are destroyed and recreated on every save (Profile#replace_*!).
#   reverted_from_id — set on a version written by a revert, pointing at the version restored.
class CreateVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.bigint   :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.jsonb    :object
      t.jsonb    :object_changes
      t.jsonb    :card_snapshot
      t.bigint   :reverted_from_id
      t.datetime :created_at, null: false
    end

    add_index :versions, %i[item_type item_id created_at]
    add_index :versions, :created_at
  end
end
