# ── Faction Seeds ──────────────────────────────────────────────────────────────
# Each file seeds its faction's CardReferences, Profiles, Weapons, and Special Rules.
Dir[File.join(__dir__, "seeds", "*.rb")].sort.each { |f| load f }

# ── Backfill card_front / card_back from profiles.json ─────────────────────────
json_path = File.expand_path("../carnevale/assets/data/profiles.json", Rails.root)
if File.exist?(json_path)
  require "json"
  json_map = JSON.parse(File.read(json_path)).each_with_object({}) do |p, h|
    h[[p["name"], p["faction"]]] = { card_front: p["front_image"], card_back: p["back_image"] }
  end
  CardReference.includes(:profile).find_each do |cr|
    entry = json_map[[cr.profile.name, cr.profile.faction]]
    cr.update_columns(entry) if entry
  end
end

puts "Total: #{CardReference.count} card references, #{Profile.count} profiles, #{Weapon.count} weapons, #{SpecialRule.count} special rules"
