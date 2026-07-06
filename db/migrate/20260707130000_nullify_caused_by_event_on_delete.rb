class NullifyCausedByEventOnDelete < ActiveRecord::Migration[8.1]
  # When a game is torn down, its agenda_events are destroyed one row at a time. The self-referential
  # caused_by_event_id FK (a recycle event points back at the discard that fed it) has no ON DELETE
  # behaviour, so deleting an event that another not-yet-deleted event still references raises a
  # ForeignKeyViolation and rolls the whole teardown back. Nullifying on delete lets the rows go in
  # any order — the provenance link is only meaningful while both rows exist anyway.
  def up
    remove_foreign_key :agenda_events, column: :caused_by_event_id
    add_foreign_key :agenda_events, :agenda_events, column: :caused_by_event_id, on_delete: :nullify
  end

  def down
    remove_foreign_key :agenda_events, column: :caused_by_event_id
    add_foreign_key :agenda_events, :agenda_events, column: :caused_by_event_id
  end
end
