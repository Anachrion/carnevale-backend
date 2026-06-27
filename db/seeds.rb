# ── Faction Seeds ──────────────────────────────────────────────────────────────
# Each file seeds its faction's CardReferences, Profiles, Weapons, and Special Rules.
Dir[File.join(__dir__, "seeds", "*.rb")].sort.each { |f| load f }

puts "Total: #{CardReference.count} card references, #{Profile.count} profiles, #{Weapon.count} weapons, #{SpecialRule.count} special rules"
