class AddRequestKeyToListEntries < ActiveRecord::Migration[8.1]
  # A client-supplied idempotency key (Idempotency-Key header) for additive hires/summons. A flaky
  # mobile client re-sends a create whose response it never received (see the builder's optimistic
  # retry queue); the partial unique index makes the retry replay the original row instead of adding
  # a duplicate. Nullable + partial so every pre-existing and key-less entry is unaffected.
  def change
    add_column :list_entries, :request_key, :string
    add_index :list_entries, [ :list_id, :request_key ], unique: true, where: "request_key IS NOT NULL",
              name: "index_list_entries_on_list_id_and_request_key"
  end
end
