class MakeListEntriesPolymorphic < ActiveRecord::Migration[8.1]
  def change
    add_column :list_entries, :enterable_type, :string
    add_column :list_entries, :enterable_id, :bigint

    reversible do |dir|
      dir.up do
        execute "UPDATE list_entries SET enterable_type = 'CardReference', enterable_id = card_reference_id"
      end
    end

    change_column_null :list_entries, :enterable_type, false
    change_column_null :list_entries, :enterable_id, false

    add_index :list_entries, [:enterable_type, :enterable_id]

    remove_foreign_key :list_entries, :card_references
    remove_column :list_entries, :card_reference_id, :bigint
  end
end
