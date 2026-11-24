# ── Rulebook data ──────────────────────────────────────────────────────────────
# Hand-authored. Scenarios, equipment and agendas live only here. Abilities and spells are the
# genesis data: the backoffice edits them since CARNEVALEB-86, and the catalog snapshot below
# carries those edits on top. Abilities come first — Profile and Weapon validate their abilities
# against that glossary, so importing the catalog before they exist fails every record.
%w[abilities spells scenarios equipment agendas].each { |f| load File.join(__dir__, "seeds", "#{f}.rb") }

# ── The catalog ────────────────────────────────────────────────────────────────
# Profiles, weapons, special rules, card references and illustrations come from db/catalog/ — the
# snapshot of what production actually holds (see bin/catalog-snapshot and docs/DATA_AND_BACKUPS.md).
#
# They used to be seeded from hand-written faction files. That made this file a second source of
# truth for data the backoffice edits, and the two had already drifted: production is authored by a
# game creator, and no one was retyping their edits back into Ruby. Seeding from the snapshot means
# a fresh install reproduces *production*, not the catalog as it was the day the seeds were written.
unless File.exist?(File.join(__dir__, "catalog", "profiles.yml"))
  abort <<~MESSAGE
    db/catalog/ is missing, so there is no catalog to seed.
    It is committed to this repo; if it has gone, `bin/catalog-snapshot` rebuilds it from production.
  MESSAGE
end

CatalogSnapshot.import

puts "Total: #{Catalog::CardReference.count} card references, #{Catalog::Profile.count} profiles, #{Catalog::Weapon.count} weapons, #{Catalog::SpecialRule.count} special rules"

# ── Spell pools ────────────────────────────────────────────────────────────────
# Imported with the profiles: the snapshot carries every pool as production has it. The one-time
# SpellPoolBackfill (lib/spell_pool_backfill.rb, still used by its migration) is no longer run here:
# it gives a standard pool to any mage without one, so it would add a pool to a profile production
# deliberately left without (CARNEVALEB-84).

# The exception profiles (non-standard spell pools and grants, flexible Leaders, companions,
# transformation pairs) are no longer configured here: the snapshot above carries them, as edited in
# the backoffice (CARNEVALEB-84). The rake tasks that once set them by hard-coded name are gone.

# ── Version card images ────────────────────────────────────────────────────────
# Bump internal_version for any card whose images changed (no-op when public/cards is empty),
# so the app knows which cards to re-download. See lib/tasks/cards.rake.
if defined?(Rake) && Rake::Task.task_defined?("cards:reversion")
  Rake::Task["cards:reversion"].invoke
end

# ── Environment-specific seeds ──────────────────────────────────────────────────
# Everything above is shared and required in every environment: the rulebook glossary and the
# catalog snapshot the whole app is built on. Everything env-specific lives in its own file and is
# loaded by Rails.env, so `rails db:seed` never leaks development accounts into production (or vice
# versa):
#
#   * development.rb — demo/test players (player1, player2, admin) and sample gangs for local work.
#   * production.rb  — the Google Play review account reviewers use to sign in and examine the app.
#
# A missing file is a no-op (e.g. the test environment seeds nothing beyond the shared data above).
env_seed = File.join(__dir__, "seeds", "#{Rails.env}.rb")
if File.exist?(env_seed)
  puts "Loading #{Rails.env} seeds…"
  load env_seed
end
