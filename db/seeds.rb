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

# ── Version card images ────────────────────────────────────────────────────────
# Bump internal_version for any card whose images changed (no-op when public/cards is empty),
# so the app knows which cards to re-download. See lib/tasks/cards.rake.
if defined?(Rake) && Rake::Task.task_defined?("cards:reversion")
  Rake::Task["cards:reversion"].invoke
end

# ── Sample List ────────────────────────────────────────────────────────────────
sample_user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.username = "demo"
  u.password = SecureRandom.hex(12)
end

# ── Dev test players (local two-player testing) ─────────────────────────────────
# Regular app users — NOT admins, so they cannot reach /backoffice.
%w[player1 player2].each do |username|
  User.find_or_create_by!(email: "#{username}@dev.local") do |u|
    u.username = username
    u.password = "password123"
  end
end

# ── Dev backoffice admin (card authoring) ───────────────────────────────────────
# The only seeded account that can sign in to /backoffice. In production, grant admin
# deliberately via `kamal console` (User.find_by(email:).update!(admin: true)).
User.find_or_create_by!(email: "admin@dev.local") do |u|
  u.username = "admin"
  u.password = "password123"
end.update!(admin: true)

list = Gang::List.find_or_create_by!(name: "Guild Sample List", faction: "guild") do |l|
  l.points = 150
  l.owner = sample_user
end

identifiers = %w[
  guild-capodecina
  guild-king-for-a-day
  guild-madame
  guild-black-lamp
  guild-prince-of-thieves
]

card_refs = Catalog::CardReference.where(identifier: identifiers).index_by(&:identifier)

list.list_entries.destroy_all
identifiers.each_with_index do |id, position|
  cr = card_refs[id]
  next unless cr
  list.list_entries.create!(entry: cr, position: position + 1)
end

puts "Seeded sample list '#{list.name}' with #{list.list_entries.count} entries."

# ── Dev test player lists (valid, 100pt, two different factions) ───────────────
def seed_dev_list(username:, list_name:, faction:, identifiers:)
  user = User.find_by!(username: username)
  list = Gang::List.find_or_create_by!(name: list_name, faction: faction) do |l|
    l.points = 100
    l.owner = user
  end

  card_refs = Catalog::CardReference.where(identifier: identifiers).index_by(&:identifier)

  list.list_entries.destroy_all
  identifiers.each_with_index do |id, position|
    cr = card_refs[id]
    next unless cr
    list.list_entries.create!(entry: cr, position: position + 1)
  end

  puts "Seeded dev list '#{list.name}' (#{faction}) for #{username} with #{list.list_entries.count} entries, valid: #{list.reload.selection_valid}."
end

# Each dev player gets several lists across different factions so multi-list flows (list picker,
# switching gangs between games) have real data to exercise. Every list is a valid 100pt gang:
# exactly one Leader, Heroes never outnumber Henchmen, total cost within the limit, no duplicated
# Unique models.
DEV_PLAYER_LISTS = {
  "player1" => [
    {
      list_name: "Player1 Guild List",
      faction: "guild",
      identifiers: %w[
        guild-king-for-a-day
        guild-arbalest-a
        guild-citizen-a
        guild-gondolier-a
        guild-harlot-a
        guild-indebted-a
        guild-mariner-a
        guild-beggar-a
        guild-blooded-a
        guild-dog-a
        guild-pulcinella-a
      ]
    },
    {
      list_name: "Player1 Rashaar List",
      faction: "rashaar",
      identifiers: %w[
        rashaar-voice-of-dagon
        rashaar-half-breed
        rashaar-cymothoan-crusher
        rashaar-advanced-hybrid-a
        rashaar-advanced-hybrid-b
        rashaar-aglaope
        rashaar-wet-nurse
      ]
    },
    {
      list_name: "Player1 Strigoi List",
      faction: "strigoi",
      identifiers: %w[
        strigoi-blood-crone
        strigoi-rotter-a
        strigoi-rotter-b
        strigoi-common-strigoi-a
        strigoi-common-strigoi-b
        strigoi-nosferatu-a
        strigoi-giurgiu-guard-a
      ]
    }
  ],
  "player2" => [
    {
      list_name: "Player2 Vatican List",
      faction: "vatican",
      identifiers: %w[
        vatican-exorcist
        vatican-altar-boy-a
        vatican-bishop-guard-a
        vatican-crucifier
        vatican-inquisitorial-spy
        vatican-martyr-a
        vatican-knight-of-malta-a
        vatican-reliquary-page
        vatican-chevaleresse-a
      ]
    },
    {
      list_name: "Player2 Patricians List",
      faction: "patricians",
      identifiers: %w[
        patricians-sopracomito
        patricians-city-guard-a
        patricians-city-guard-b
        patricians-butler-a
        patricians-household-staff-a
        patricians-naval-recruit-a
        patricians-ottoman-archer
        patricians-hired-muscle
        patricians-hunting-hound-a
      ]
    },
    {
      list_name: "Player2 Doctors List",
      faction: "doctors",
      identifiers: %w[
        doctors-master-of-zoology
        doctors-husk-a
        doctors-husk-b
        doctors-madman-a
        doctors-madman-b
        doctors-ghoul-a
        doctors-ghoul-b
        doctors-hollowman-a
        doctors-nurse-a
        doctors-monstrosity
        doctors-carrion-a
      ]
    }
  ]
}

DEV_PLAYER_LISTS.each do |username, lists|
  lists.each { |attrs| seed_dev_list(username: username, **attrs) }
end
