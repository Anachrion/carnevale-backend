require Rails.root.join("lib/spell_pool_backfill")

class BackfillStandardSpellPools < ActiveRecord::Migration[8.1]
  def up
    # Reused by db/seeds.rb too (see its comment): a fresh install has no profiles yet at migration
    # time, only once the catalog snapshot is imported afterward, so this call here is what handles
    # existing production data specifically.
    say_with_time("Backfilling one standard spell pool per mage profile") { SpellPoolBackfill.call }

    say_with_time "Migrating existing entry spell/discipline picks onto their profile's pool" do
      # Set-based rather than N+1: join each Mage list_entry to its profile's card_reference (the
      # entry's polymorphic target when entry_type is Catalog::CardReference) to the pool the first
      # step just created for that profile. A fresh install has none of these rows yet, so this is a
      # no-op there; it only matters for existing production data.
      execute <<~SQL.squish
        INSERT INTO entry_pool_disciplines (list_entry_id, pool_id, discipline, created_at, updated_at)
        SELECT le.id, sp.id, le.spell_discipline, NOW(), NOW()
        FROM list_entries le
        INNER JOIN card_references cr ON cr.id = le.entry_id AND le.entry_type = 'Catalog::CardReference'
        INNER JOIN profile_spell_pools sp ON sp.profile_id = cr.profile_id AND sp.position = 1
        WHERE le.spell_discipline IS NOT NULL
      SQL

      execute <<~SQL.squish
        UPDATE entry_spells es
        SET pool_id = sp.id
        FROM list_entries le
        INNER JOIN card_references cr ON cr.id = le.entry_id AND le.entry_type = 'Catalog::CardReference'
        INNER JOIN profile_spell_pools sp ON sp.profile_id = cr.profile_id AND sp.position = 1
        WHERE es.list_entry_id = le.id
      SQL
    end
  end

  def down
    # One-time backfill on data that no longer exists in the old shape once this migration's sibling
    # schema migrations run — not meaningfully reversible. Rolling back drops the tables/columns this
    # data lived in anyway (see the migrations that create them).
    raise ActiveRecord::IrreversibleMigration
  end
end
