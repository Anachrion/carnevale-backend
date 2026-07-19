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

    # A snapshot whose source list was deleted before this FK existed still points at a now-missing
    # id (seen in prod: source_list_id=20 with no lists.id=20). on_delete: :nullify is exactly that
    # semantics, so null the pre-existing orphans first, otherwise adding the FK below is rejected.
    up_only do
      execute(<<~SQL)
        UPDATE lists AS l
        SET source_list_id = NULL
        WHERE l.source_list_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM lists AS p WHERE p.id = l.source_list_id)
      SQL
    end

    add_foreign_key :lists, :lists, column: :source_list_id, on_delete: :nullify
  end
end
