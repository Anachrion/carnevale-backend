class CreateProfileCompanions < ActiveRecord::Migration[8.1]
  # CARNEVALEB-23: which models a profile automatically brings into a gang, and how many. The
  # Emissary of Mother Hydra takes 1 of each Tentacle (base_quantity) or 2 of each once its
  # +12-Ducat upgrade is bought (upgraded_quantity). Modelled as data, not code, so a future
  # "brings companions" profile only needs seed rows.
  def up
    create_table :profile_companions do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :companion_profile, null: false, foreign_key: { to_table: :profiles }
      t.integer :base_quantity, null: false, default: 1
      t.integer :upgraded_quantity, null: false, default: 1
      t.timestamps
    end
    add_index :profile_companions, [ :profile_id, :companion_profile_id ], unique: true, name: "index_profile_companions_on_profile_and_companion"

    # Wire the Emissary to its four Tentacles inline for existing production data (a fresh install
    # has no profiles yet — companions:configure_exceptions handles that after the catalog import).
    say_with_time "Wiring the Emissary of Mother Hydra to its Tentacles" do
      execute(<<~SQL)
        INSERT INTO profile_companions (profile_id, companion_profile_id, base_quantity, upgraded_quantity, created_at, updated_at)
        SELECT emissary.id, tentacle.id, 1, 2, NOW(), NOW()
        FROM profiles emissary, profiles tentacle
        WHERE emissary.name = 'Emissary of Mother Hydra'
          AND tentacle.name IN ('Dagger Tentacle', 'Lash Tentacle', 'Maw Tentacle', 'Thorn Tentacle')
      SQL
    end
  end

  def down
    drop_table :profile_companions
  end
end
