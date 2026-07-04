# ── Faction Seeds ──────────────────────────────────────────────────────────────
# Each file seeds its faction's CardReferences, Profiles, Weapons, and Special Rules.
Dir[File.join(__dir__, "seeds", "*.rb")].sort.each { |f| load f }

# ── Backfill card_front / card_back from profiles.json ─────────────────────────
json_path = File.expand_path("../carnevale/assets/data/profiles.json", Rails.root)
if File.exist?(json_path)
  require "json"
  json_map = JSON.parse(File.read(json_path)).each_with_object({}) do |p, h|
    h[[p["name"], p["faction"]]] = { card_front: File.basename(p["front_image"]), card_back: File.basename(p["back_image"]) }
  end
  CardReference.includes(:profile).find_each do |cr|
    entry = json_map[[cr.profile.name, cr.profile.faction]]
    cr.update_columns(entry) if entry
  end
end

puts "Total: #{CardReference.count} card references, #{Profile.count} profiles, #{Weapon.count} weapons, #{SpecialRule.count} special rules"

# ── Sample List ────────────────────────────────────────────────────────────────
sample_user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.username = "demo"
  u.password = SecureRandom.hex(12)
end

# ── Dev test players (local two-player testing) ─────────────────────────────────
%w[player1 player2].each do |username|
  User.find_or_create_by!(email: "#{username}@dev.local") do |u|
    u.username = username
    u.password = "password123"
  end
end

list = List.find_or_create_by!(name: "Guild Sample List", faction: "guild") do |l|
  l.points = 150
  l.user = sample_user
end

identifiers = %w[
  guild-capodecina
  guild-king-for-a-day
  guild-madame
  guild-black-lamp
  guild-prince-of-thieves
]

card_refs = CardReference.where(identifier: identifiers).index_by(&:identifier)

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
  list = List.find_or_create_by!(name: list_name, faction: faction) do |l|
    l.points = 100
    l.user = user
  end

  card_refs = CardReference.where(identifier: identifiers).index_by(&:identifier)

  list.list_entries.destroy_all
  identifiers.each_with_index do |id, position|
    cr = card_refs[id]
    next unless cr
    list.list_entries.create!(entry: cr, position: position + 1)
  end

  puts "Seeded dev list '#{list.name}' (#{faction}) for #{username} with #{list.list_entries.count} entries, valid: #{list.reload.selection_valid}."
end

seed_dev_list(
  username: "player1",
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
)

seed_dev_list(
  username: "player2",
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
)
