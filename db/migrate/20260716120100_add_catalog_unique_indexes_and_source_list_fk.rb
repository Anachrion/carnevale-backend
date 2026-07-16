class AddCatalogUniqueIndexesAndSourceListFk < ActiveRecord::Migration[8.1]
  # Back the uniqueness validations that had no database index (agendas.name, scenarios.name,
  # spells (name, discipline)) with real unique indexes, so a concurrent seed / double-submitted
  # import can't insert the duplicates the models believe are impossible. And add the missing
  # foreign key on lists.source_list_id so deleting a source list nullifies the snapshot's pointer
  # instead of leaving it dangling (serialized to clients). B-26.
  def change
    add_index :agendas, :name, unique: true
    add_index :scenarios, :name, unique: true
    add_index :spells, [:name, :discipline], unique: true

    add_foreign_key :lists, :lists, column: :source_list_id, on_delete: :nullify
  end
end
