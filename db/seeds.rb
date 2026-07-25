# ── Rulebook data ──────────────────────────────────────────────────────────────
# Hand-authored, and rightly so: the backoffice cannot edit any of it, so git is where it is
# written and where it belongs. Abilities come first — Profile and Weapon validate their abilities
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
# The one-time backfill migration only sees profiles that already existed when it ran — a fresh
# install has none yet, since the catalog is imported above, *after* migrations run. Call it again
# here; it's idempotent (skips any profile that already has a pool), so this is a no-op on a
# database where the migration already did the work against real data.
require Rails.root.join("lib/spell_pool_backfill")
puts "Backfilled #{SpellPoolBackfill.call} standard spell pools."

# The ~10 profiles whose spell pools/grants aren't the standard shape (Doctor of the Firmament,
# Seamstress, Apprentice Doctor, …) — see lib/tasks/spell_pool_exceptions.rake. Idempotent, same
# reasoning as the backfill above: always safe to (re-)run against a fresh install.
if defined?(Rake) && Rake::Task.task_defined?("spell_pools:configure_exceptions")
  Rake::Task["spell_pools:configure_exceptions"].invoke
end

# The Leaders that may be hired alongside another Leader (The Duke, Prince of Thieves, Sopracomito,
# La Signora) — flag them so the gang builder keeps offering them; see lib/tasks/leader_exceptions.rake.
# Idempotent, same reasoning as the spell-pool exceptions above.
if defined?(Rake) && Rake::Task.task_defined?("leaders:configure_exceptions")
  Rake::Task["leaders:configure_exceptions"].invoke
end

# The models that can only arrive as another model's companion (the Emissary of Mother Hydra's
# Tentacles) and the Emissary's auto-included companions + paid upgrade; see
# lib/tasks/companions.rake. Idempotent, same reasoning as the exceptions above.
if defined?(Rake) && Rake::Task.task_defined?("companions:configure_exceptions")
  Rake::Task["companions:configure_exceptions"].invoke
end

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
