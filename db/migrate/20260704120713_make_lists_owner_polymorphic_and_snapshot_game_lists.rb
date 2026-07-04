class MakeListsOwnerPolymorphicAndSnapshotGameLists < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :lists, :users
    add_column :lists, :owner_type, :string
    rename_column :lists, :user_id, :owner_id
    execute "UPDATE lists SET owner_type = 'User'"
    change_column_null :lists, :owner_type, false
    remove_index :lists, name: "index_lists_on_owner_id"
    add_index :lists, [ :owner_type, :owner_id ], name: "index_lists_on_owner"

    # Any game_player that had already selected a (live, user-owned) list gets its own frozen
    # copy, so this migration doesn't change behavior for in-flight games once list_id is
    # dropped below.
    execute <<~SQL
      DO $$
      DECLARE
        gp RECORD;
        new_list_id BIGINT;
      BEGIN
        FOR gp IN
          SELECT game_players.id AS game_player_id, lists.id AS list_id, lists.name, lists.faction,
                 lists.points, lists.selection_valid, lists.selection_errors
          FROM game_players JOIN lists ON lists.id = game_players.list_id
          WHERE game_players.list_id IS NOT NULL
        LOOP
          INSERT INTO lists (owner_type, owner_id, name, faction, points, selection_valid, selection_errors, created_at, updated_at)
          VALUES ('GamePlayer', gp.game_player_id, gp.name, gp.faction, gp.points, gp.selection_valid, gp.selection_errors, NOW(), NOW())
          RETURNING id INTO new_list_id;

          INSERT INTO list_entries (list_id, entry_type, entry_id, position, created_at, updated_at)
          SELECT new_list_id, entry_type, entry_id, position, NOW(), NOW()
          FROM list_entries WHERE list_id = gp.list_id;
        END LOOP;
      END $$;
    SQL

    remove_column :game_players, :list_id
  end

  def down
    add_column :game_players, :list_id, :bigint
    add_index :game_players, :list_id
    add_foreign_key :game_players, :lists

    # The frozen per-game snapshots have no equivalent in the pre-polymorphic schema (a
    # game_player used to point directly at a live, user-owned list) — dropping this feature
    # necessarily drops the data it introduced, leaving those game_players' list_id NULL.
    execute <<~SQL
      DELETE FROM list_entries USING lists
      WHERE lists.id = list_entries.list_id AND lists.owner_type = 'GamePlayer'
    SQL
    execute "DELETE FROM lists WHERE owner_type = 'GamePlayer'"

    remove_index :lists, name: "index_lists_on_owner"
    rename_column :lists, :owner_id, :user_id
    remove_column :lists, :owner_type
    add_index :lists, :user_id, name: "index_lists_on_user_id"
    add_foreign_key :lists, :users
  end
end
