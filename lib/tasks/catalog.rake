namespace :catalog do
  # Snapshot the authored catalog (profiles, weapons, special rules, illustration records and the
  # uploaded art) to db/catalog/ as versioned YAML + LFS blobs. The catalog is authored in the
  # backoffice and lives only in the database, so this is its off-box backup and its reviewable
  # history. Run it wherever the authoritative data is — in production, via `kamal app exec`.
  desc "Export the catalog to db/catalog/ (records as YAML, uploaded art as blobs)"
  task export: :environment do
    result = CatalogSnapshot.export
    puts "catalog:export — #{result[:profiles]} profiles, #{result[:weapons]} weapons, " \
         "#{result[:special_rules]} special rules, #{result[:blobs]} illustration blob(s) → db/catalog/"
  end

  # Rebuild the catalog from db/catalog/ into this environment's database. Additive and idempotent:
  # safe on a fresh database (a new production, a teammate's machine) and safe to re-run. It never
  # deletes, so it will not cascade through player data.
  desc "Import the catalog from db/catalog/"
  task import: :environment do
    tally = CatalogSnapshot.import
    puts "catalog:import — profiles: +#{tally[:profiles_created]} new, #{tally[:profiles_updated]} updated; " \
         "weapons: +#{tally[:weapons]}, special rules: +#{tally[:special_rules]}"
  end
end
