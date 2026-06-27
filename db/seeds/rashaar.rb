# ── Card References ────────────────────────────────────────────────────────────
card_ref_data = [
  { name: "The Flame That Burns Underwater", identifier: "rashaar-the-flame-that-burns-underwater", cost: 30 },
  { name: "Magi-Rashaar",                   identifier: "rashaar-magi-rashaar",                    cost: 24 },
  { name: "Paartul Matriarch",              identifier: "rashaar-paartul-matriarch",               cost: 25 },
  { name: "Sir Tiburcio",                   identifier: "rashaar-sir-tiburcio",                    cost: 23 },
  { name: "Thalidraur",                     identifier: "rashaar-thalidraur",                      cost: 26 },
  { name: "Voice of Dagon",                 identifier: "rashaar-voice-of-dagon",                  cost: 20 },
  { name: "Morgraur",                       identifier: "rashaar-morgraur",                        cost: 68 },
  { name: "Emissary of Mother Hydra",       identifier: "rashaar-emissary-of-mother-hydra",        cost: 51 },
  { name: "Maw Tentacle",                   identifier: "rashaar-maw-tentacle",                    cost:  0 },
  { name: "Lash Tentacle",                  identifier: "rashaar-lash-tentacle",                   cost:  0 },
  { name: "Dagger Tentacle",                identifier: "rashaar-dagger-tentacle",                 cost:  0 },
  { name: "Thorn Tentacle",                 identifier: "rashaar-thorn-tentacle",                  cost:  0 },
  { name: "The Drowned Nun",                identifier: "rashaar-the-drowned-nun",                 cost: 18 },
  { name: "Brachyura",                      identifier: "rashaar-brachyura-a",                     cost: 18 },
  { name: "Brachyura",                      identifier: "rashaar-brachyura-b",                     cost: 18 },
  { name: "Caandru Eel",                    identifier: "rashaar-caandru-eel",                     cost: 14 },
  { name: "Cult Enforcer",                  identifier: "rashaar-cult-enforcer",                   cost: 14 },
  { name: "Dagonite Priest",                identifier: "rashaar-dagonite-priest",                 cost: 15 },
  { name: "Demagogue",                      identifier: "rashaar-demagogue",                       cost: 15 },
  { name: "Handler",                        identifier: "rashaar-handler",                         cost: 12 },
  { name: "Karcharos",                      identifier: "rashaar-karcharos",                       cost: 18 },
  { name: "Krakenhost",                     identifier: "rashaar-krakenhost",                      cost: 17 },
  { name: "Mature Kraken",                  identifier: "rashaar-mature-kraken",                   cost: 24 },
  { name: "Paliaa",                         identifier: "rashaar-paliaa",                          cost: 19 },
  { name: "Raadru",                         identifier: "rashaar-raadru",                          cost: 20 },
  { name: "Salaacia",                       identifier: "rashaar-salaacia",                        cost: 16 },
  { name: "Secreting Myxin",                identifier: "rashaar-secreting-myxin",                 cost: 23 },
  { name: "Sirena",                         identifier: "rashaar-sirena",                          cost: 18 },
  { name: "Tainted Maw",                    identifier: "rashaar-tainted-maw",                     cost: 18 },
  { name: "Advanced Hybrid",                identifier: "rashaar-advanced-hybrid-a",               cost: 12 },
  { name: "Advanced Hybrid",                identifier: "rashaar-advanced-hybrid-b",               cost: 12 },
  { name: "Aglaope",                        identifier: "rashaar-aglaope",                         cost: 12 },
  { name: "Bounding Telebine",              identifier: "rashaar-bounding-telebine",               cost:  9 },
  { name: "Bulbous Toad",                   identifier: "rashaar-bulbous-toad",                    cost: 13 },
  { name: "Crybaby",                        identifier: "rashaar-crybaby-a",                       cost:  0 },
  { name: "Crybaby",                        identifier: "rashaar-crybaby-b",                       cost:  0 },
  { name: "Cymothoan Crusher",              identifier: "rashaar-cymothoan-crusher",               cost: 17 },
  { name: "Dagon Officiant",                identifier: "rashaar-dagon-officiant-a",               cost:  0 },
  { name: "Dagon Officiant",                identifier: "rashaar-dagon-officiant-b",               cost:  0 },
  { name: "Dagonite Page",                  identifier: "rashaar-dagonite-page",                   cost: 13 },
  { name: "Dagonite Zealot",                identifier: "rashaar-dagonite-zealot-a",               cost:  0 },
  { name: "Dagonite Zealot",                identifier: "rashaar-dagonite-zealot-b",               cost:  0 },
  { name: "Encrusted Squire",               identifier: "rashaar-encrusted-squire",                cost: 12 },
  { name: "Half-Breed",                     identifier: "rashaar-half-breed",                      cost: 16 },
  { name: "Hellhound",                      identifier: "rashaar-hellhound",                       cost: 10 },
  { name: "Hybrid",                         identifier: "rashaar-hybrid-a",                        cost:  9 },
  { name: "Hybrid",                         identifier: "rashaar-hybrid-b",                        cost:  9 },
  { name: "Infant Kraken",                  identifier: "rashaar-infant-kraken-a",                 cost:  0 },
  { name: "Infant Kraken",                  identifier: "rashaar-infant-kraken-b",                 cost:  0 },
  { name: "Lesser Rhyll",                   identifier: "rashaar-lesser-rhyll",                    cost: 13 },
  { name: "Lesser Ugdru",                   identifier: "rashaar-lesser-ugdru-a",                  cost: 14 },
  { name: "Lesser Ugdru",                   identifier: "rashaar-lesser-ugdru-b",                  cost: 14 },
  { name: "Slave",                          identifier: "rashaar-slave-a",                         cost:  0 },
  { name: "Slave",                          identifier: "rashaar-slave-b",                         cost:  0 },
  { name: "Urchin",                         identifier: "rashaar-urchin-a",                        cost:  8 },
  { name: "Urchin",                         identifier: "rashaar-urchin-b",                        cost:  8 },
  { name: "Wet Nurse",                      identifier: "rashaar-wet-nurse",                       cost: 10 },
]

now = Time.current
records = card_ref_data.map do |attrs|
  display_name = case attrs[:identifier]
                 when /-a$/ then "#{attrs[:name]} (A)"
                 when /-b$/ then "#{attrs[:name]} (B)"
                 else attrs[:name]
                 end
  { name: display_name, identifier: attrs[:identifier], faction: "rashaar", cost: attrs[:cost], created_at: now, updated_at: now }
end
CardReference.upsert_all(records, unique_by: :identifier, update_only: %i[name faction cost])

# Rashaar faction seeds — first half (24 of 47 profiles).
# Idempotent — safe to run multiple times. Load from db/seeds.rb.

# ── Special Rules ──────────────────────────────────────────────────────────────

hydras_gifts = SpecialRule.find_or_create_by!(name: "Hydra's Gifts") do |r|
  r.description = "PULSE Command Ability. Mutating tentacles emerge from flesh nearby. Every other character (friendly and enemy, not including this one) within 2\" loses 2 Life Points and gains +2 DEXTERITY until the end of the round."
end
dragging_down = SpecialRule.find_or_create_by!(name: "Dragging Down") do |r|
  r.description = "This character may re-roll failed dice rolls when making Drown actions."
end
brawling_tentacles_sr = SpecialRule.find_or_create_by!(name: "Brawling Tentacles") do |r|
  r.description = "The Flame's tentacles thrash around, hitting anyone that gets close! When making a Combat action with this weapon, roll once, and apply the roll to every character (friendly and enemy) in base contact."
end
fury_of_dagon = SpecialRule.find_or_create_by!(name: "Fury of Dagon") do |r|
  r.description = "PULSE Command Ability. Pick a friendly character in line of sight within 6\". That character gains First Strike (2) until the end of their next turn."
end
rent_born = SpecialRule.find_or_create_by!(name: "Rent-born") do |r|
  r.description = "Each round, one friendly character (including this one) may subtract 1 from the Cost of a Magic Spell they attempt to cast (to a minimum of 0)."
end
birth = SpecialRule.find_or_create_by!(name: "Birth") do |r|
  r.description = "PULSE Command Ability. Place one Crybaby within 6\" of this character. The new Crybaby acts just like any other friendly character, and can be activated this round as normal."
end
matriarch = SpecialRule.find_or_create_by!(name: "Matriarch") do |r|
  r.description = "All friendly characters with the Feral keyword gain Companion (Leader) as long as this character is on the board."
end
postpartum = SpecialRule.find_or_create_by!(name: "Postpartum") do |r|
  r.description = "If one or more Crybabies are killed within 6\" of this character, it gains +3 ATT for the rest of the round."
end
shield_to_the_enlightened = SpecialRule.find_or_create_by!(name: "Shield to the Enlightened") do |r|
  r.description = "PULSE Command Ability. Until the end of the round, all friendly characters within 3\" gain Universal Shielding (3). Additionally, until the end of the round, all friendly characters with the Feral keyword within 3\" gain Expert Protection (1)."
end
vatican_apostate = SpecialRule.find_or_create_by!(name: "Vatican Apostate") do |r|
  r.description = "This character can re-roll the destiny dice when making Attack or Protection rolls."
end
dead_weight = SpecialRule.find_or_create_by!(name: "Dead Weight") do |r|
  r.description = "This character gains +1 PROTECTION while in water (in addition to any cover bonuses), but cannot make Dive actions."
end
hide_of_the_deep = SpecialRule.find_or_create_by!(name: "Hide of The Deep") do |r|
  r.description = "AURA Command Ability. Until the end of the round, all friendly characters within 3\" of this character gain Expert Protection (2)."
end
foetid_pheromones = SpecialRule.find_or_create_by!(name: "Foetid Pheromones") do |r|
  r.description = "Other friendly characters that start their activation within 6\" of this character gain First Strike (1) until the end of their activation."
end
lead_through_fear = SpecialRule.find_or_create_by!(name: "Lead Through Fear") do |r|
  r.description = "Whenever another character (friendly or enemy) is killed within 6\" of this character, this character replenishes 1 Command Point and 1 Will Point."
end
blessing_of_dagon = SpecialRule.find_or_create_by!(name: "Blessing of Dagon") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 6\" gain Expert Offence (2)."
end
herald_of_an_old_god = SpecialRule.find_or_create_by!(name: "Herald of an Old God") do |r|
  r.description = "Whenever this character uses an ORDER or COUNTER Command, roll a dice. On a 7+ this Command doesn't use a Command Point."
end
serpentine = SpecialRule.find_or_create_by!(name: "Serpentine") do |r|
  r.description = "This character is able to move through spaces smaller than its base to a minimum of 2\". It must be able to fit where it ends its turn."
end
swallow_whole = SpecialRule.find_or_create_by!(name: "Swallow Whole") do |r|
  r.description = "When this character makes a Combat action (not an Attack of Opportunity) against a target character with a Size of 40mm or less and rolls at least 5 Aces, instead of calculating Damage as normal, instead immediately remove the target character from play as a casualty."
end
grasp_of_the_abyss = SpecialRule.find_or_create_by!(name: "Grasp of the Abyss") do |r|
  r.description = "A gang that includes this character also automatically includes the following (and count towards Henchman taken): 1 Maw Tentacle, 1 Lash Tentacle, 1 Dagger Tentacle, 1 Thorn Tentacle. You may pay an additional 12 Ducats to take 2 of each Tentacle instead. After you complete this character's activation, place each of its remaining Tentacles within 6\" of it."
end
rip_apart = SpecialRule.find_or_create_by!(name: "Rip Apart") do |r|
  r.description = "When one of this character's Tentacles kills an enemy character, this character replenishes 1 Will Point."
end
part_of_the_whole = SpecialRule.find_or_create_by!(name: "Part of the Whole") do |r|
  r.description = "This character can only be taken with the Emissary of Mother Hydra and cannot move or be moved further than 6\" from it. At the end of each enemy turn, if this character is further than 6\" away from the Emissary, it moves the shortest distance to be within 6\" of it, ignoring disengaging or charging. If the Emissary is killed, this character is also killed."
end
fanaticism_for_dagon = SpecialRule.find_or_create_by!(name: "Fanaticism For Dagon") do |r|
  r.description = "PULSE Command Ability. Friendly characters in line of sight within 3\" lose 1 Life Point and gain Frenzied until the end of the round."
end
truth_of_dagon = SpecialRule.find_or_create_by!(name: "Truth of Dagon") do |r|
  r.description = "Whenever an enemy character in line of sight loses life due to Drowning or Dagonite Baptism, it must roll a Basic MIND roll. If it rolls no Aces, it receives a Stunned counter."
end
dagonite_baptism = SpecialRule.find_or_initialize_by(spell_name: "Dagonite Baptism").tap do |r|
  r.name              = ""
  r.description       = "The Drowned Nun may use the following unique Magic Spell. This spell cannot be used by other characters. She knows this in addition to any other spells."
  r.spell_cost        = 1
  r.spell_difficulty  = 6
  r.spell_description = "Total up every Ace rolled then pick one enemy character in line of sight within 3\". That character loses that many Life Points plus 1."
  r.save!
end
patient_hunter = SpecialRule.find_or_create_by!(name: "Patient Hunter") do |r|
  r.description = "If this character exits water and charges in the same action, it counts as charging from above."
end
bolster_your_faith = SpecialRule.find_or_create_by!(name: "Bolster Your Faith") do |r|
  r.description = "AURA Command Ability. Until the end of the round, all friendly characters within 3\" gain +1 PROTECTION."
end
sacrifice = SpecialRule.find_or_create_by!(name: "Sacrifice") do |r|
  r.description = "For every Life Point this character causes a character to lose with a Combat action using the Sacrificial Dagger, it replenishes 1 Will Point. This character may make Combat actions against friendly characters."
end
prove_yourselves_to_dagon = SpecialRule.find_or_create_by!(name: "Prove Yourselves to Dagon!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly character that starts a Run/Climb action within 6\" gains +2 MOVE for that action provided they charge."
end
eldritch_incense = SpecialRule.find_or_create_by!(name: "Eldritch Incense") do |r|
  r.description = "Any friendly character making a Combat action within 3\" gains Fear (0) for that action."
end
burned_flesh = SpecialRule.find_or_create_by!(name: "Burned Flesh") do |r|
  r.description = "If a Combat action with the Burning Brand results in no Protection roll for the target, add 2 to the Damage."
end
herding = SpecialRule.find_or_create_by!(name: "Herding") do |r|
  r.description = "Any friendly character with the Monster keyword that starts a Run/Climb action within 2\" of one or more characters with this rule gains +2\" MOVE for that action."
end
encouragement_handler = SpecialRule.find_or_create_by!(name: "Encouragement") do |r|
  r.description = "Friendly characters with the Feral keyword that start their turn within 6\" and line of sight of this character automatically pass their Primitive roll."
end
spawn_3lp = SpecialRule.find_or_create_by!(name: "Spawn - 3LP") do |r|
  r.description = "Place a new Infant Kraken in base contact with this character. The new Infant Kraken acts just like any other friendly character, and can be activated this round as normal. This ability may only be used once each round and only if this character has 4 or more Life Points remaining."
end
living_vessel = SpecialRule.find_or_create_by!(name: "Living Vessel") do |r|
  r.description = "When this character is killed, before removing it from the game, make a basic MIND roll. Place an Infant Kraken in base contact with this character, plus an additional Infant Kraken for each Ace in the roll. The new Infant Krakens act just like any other friendly character and can be activated as normal this round."
end
climbing_suckers = SpecialRule.find_or_create_by!(name: "Climbing Suckers") do |r|
  r.description = "When this character makes a DEXTERITY roll as part of a Run/Climb action, it counts all fumbles as failures."
end
gift_of_the_elder_gods = SpecialRule.find_or_create_by!(name: "Gift of the Elder Gods") do |r|
  r.description = "PULSE Command Ability. Until the end of the round, all friendly characters with the Henchman keyword gain +1 ATTACK while they are within 6\" and line of sight of any number of other friendly characters with the Monster keyword."
end

# ── Weapons ───────────────────────────────────────────────────────────────────

brawling_tentacles_w = Weapon.find_or_create_by!(name: "Brawling Tentacles") { |w| w.range = 0;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
ornate_trident       = Weapon.find_or_create_by!(name: "Ornate Trident")     { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic"] }
ancient_trident      = Weapon.find_or_create_by!(name: "Ancient Trident")    { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic", "Two-handed"] }
unarmed              = Weapon.find_or_create_by!(name: "Unarmed")            { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }
barnacle_claymore    = Weapon.find_or_create_by!(name: "Barnacle Claymore")  { |w| w.range = 1;  w.evasion = 1;  w.damage = 1;  w.penetration = -1; w.abilities = ["Two-handed", "Knockback"] }
ancient_claws        = Weapon.find_or_create_by!(name: "Ancient Claws")      { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
golden_tipped_claws  = Weapon.find_or_create_by!(name: "Golden Tipped Claws"){ |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = [] }
voice_of_madness     = Weapon.find_or_create_by!(name: "Voice of Madness")   { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = -3; w.abilities = ["Stun", "Template"] }
colossal_jaws        = Weapon.find_or_create_by!(name: "Colossal Jaws")      { |w| w.range = 2;  w.evasion = 2;  w.damage = 2;  w.penetration = -3; w.abilities = ["Aquatic"] }
eldritch_maw         = Weapon.find_or_create_by!(name: "Eldritch Maw")       { |w| w.range = 1;  w.evasion = 0;  w.damage = 0;  w.penetration = -4; w.abilities = ["Aquatic"] }
fanged_maw           = Weapon.find_or_create_by!(name: "Fanged Maw")         { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
lashing_swipe        = Weapon.find_or_create_by!(name: "Lashing Swipe")      { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = -1; w.abilities = [] }
rending_spine        = Weapon.find_or_create_by!(name: "Rending Spine")      { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Knockback"] }
thorned_grasp        = Weapon.find_or_create_by!(name: "Thorned Grasp")      { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Stun"] }
staff                = Weapon.find_or_create_by!(name: "Staff")              { |w| w.range = 1;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
crushing_claws       = Weapon.find_or_create_by!(name: "Crushing Claws")     { |w| w.range = 0;  w.evasion = 2;  w.damage = 3;  w.penetration = 0;  w.abilities = ["Aquatic"] }
mauling_talons       = Weapon.find_or_create_by!(name: "Mauling Talons")     { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic"] }
iron_mace            = Weapon.find_or_create_by!(name: "Iron Mace")          { |w| w.range = 1;  w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Stun"] }
sacrificial_dagger   = Weapon.find_or_create_by!(name: "Sacrificial Dagger") { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
burning_brand        = Weapon.find_or_create_by!(name: "Burning Brand")      { |w| w.range = 2;  w.evasion = 0;  w.damage = 0;  w.penetration = -3; w.abilities = ["Smoke", "Two-handed"] }
herding_spear        = Weapon.find_or_create_by!(name: "Herding Spear")      { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Knockback", "Two-handed"] }
mighty_jaws          = Weapon.find_or_create_by!(name: "Mighty Jaws")        { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -3; w.abilities = ["Aquatic"] }
barbed_tentacles     = Weapon.find_or_create_by!(name: "Barbed Tentacles")   { |w| w.range = 2;  w.evasion = 0;  w.damage = -1; w.penetration = -2; w.abilities = ["Aquatic", "Stun"] }
# NOTE: Paliaa and Lesser Ugdru both have a weapon printed as "Claws" but with
# different stats (Paliaa: Damage 0; Ugdru: Damage +1). We key the lookup on
# name + damage so both records coexist and each profile links to the right one.
claws                = Weapon.find_or_create_by!(name: "Claws", damage: 0)    { |w| w.range = 0;  w.evasion = 0;  w.penetration = -1; w.abilities = ["Aquatic"] }
webbed_fists         = Weapon.find_or_create_by!(name: "Webbed Fists")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 2;  w.penetration = 0;  w.abilities = [] }

# ── Leaders ───────────────────────────────────────────────────────────────────

flame_that_burns = Profile.find_or_create_by!(name: "The Flame That Burns Underwater") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 22; p.will_points = 5; p.command_points = 4
  p.size = 50; p.ducats = 30; p.movement = 3; p.dexterity = 3; p.attack = 4; p.protection = 5; p.mind = 5
  p.keywords = ["Leader", "Hydra", "Monster", "Unique"]
  p.abilities = ["Bulky", "Expert Grappler (3)", "Fast Swimmer (3)", "Limited Movement", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: flame_that_burns, weapon: brawling_tentacles_w) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: flame_that_burns, weapon: ornate_trident)       { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: flame_that_burns, special_rule: hydras_gifts)          { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: flame_that_burns, special_rule: dragging_down)         { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: flame_that_burns, special_rule: brawling_tentacles_sr) { |psr| psr.position = 2 }

magi_rashaar = Profile.find_or_create_by!(name: "Magi-Rashaar") do |p|
  p.version = "2.2.1"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 12; p.will_points = 5; p.command_points = 4
  p.size = 30; p.ducats = 24; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 6
  p.keywords = ["Leader", "Discipline (Blood Rites, Runes of Sovereignty, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (2)", "Fast Swimmer (1)", "Mage (3)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: magi_rashaar, weapon: ancient_trident) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: magi_rashaar, special_rule: fury_of_dagon) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: magi_rashaar, special_rule: rent_born)     { |psr| psr.position = 1 }

paartul_matriarch = Profile.find_or_create_by!(name: "Paartul Matriarch") do |p|
  p.version = "2.2.1"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 22; p.will_points = 4; p.command_points = 4
  p.size = 50; p.ducats = 25; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["Leader", "Monster"]
  p.abilities = ["Bulky", "Fear (-1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: paartul_matriarch, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: paartul_matriarch, special_rule: birth)      { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: paartul_matriarch, special_rule: matriarch)  { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: paartul_matriarch, special_rule: postpartum) { |psr| psr.position = 2 }

sir_tiburcio = Profile.find_or_create_by!(name: "Sir Tiburcio") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 16; p.will_points = 3; p.command_points = 3
  p.size = 40; p.ducats = 23; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 4
  p.keywords = ["Leader", "Unique"]
  p.abilities = ["Brawler (1)", "Expert Offence (2)", "Fast Swimmer (1)", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: sir_tiburcio, weapon: barnacle_claymore) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sir_tiburcio, special_rule: shield_to_the_enlightened) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sir_tiburcio, special_rule: vatican_apostate)          { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: sir_tiburcio, special_rule: dead_weight)               { |psr| psr.position = 2 }

thalidraur = Profile.find_or_create_by!(name: "Thalidraur") do |p|
  p.version = "2.2.1"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 20; p.will_points = 3; p.command_points = 1
  p.size = 50; p.ducats = 26; p.movement = 3; p.dexterity = 3; p.attack = 5; p.protection = 5; p.mind = 3
  p.keywords = ["Leader", "Monster"]
  p.abilities = ["Expert Offence (2)", "Fast Swimmer (2)", "Fear (-2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: thalidraur, weapon: ancient_claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: thalidraur, special_rule: hide_of_the_deep)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: thalidraur, special_rule: foetid_pheromones)  { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: thalidraur, special_rule: lead_through_fear)  { |psr| psr.position = 2 }

voice_of_dagon = Profile.find_or_create_by!(name: "Voice of Dagon") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 14; p.will_points = 3; p.command_points = 5
  p.size = 40; p.ducats = 20; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 4
  p.keywords = ["Leader", "Monster"]
  p.abilities = ["Universal Shielding (4)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: voice_of_dagon, weapon: golden_tipped_claws) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: voice_of_dagon, weapon: voice_of_madness)    { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: voice_of_dagon, special_rule: blessing_of_dagon)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: voice_of_dagon, special_rule: herald_of_an_old_god) { |psr| psr.position = 1 }

# ── Heroes ────────────────────────────────────────────────────────────────────

morgraur = Profile.find_or_create_by!(name: "Morgraur") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 45; p.will_points = 1; p.command_points = 0
  p.size = 120; p.ducats = 68; p.movement = 5; p.dexterity = 3; p.attack = 6; p.protection = 5; p.mind = 1
  p.keywords = ["Hero", "Monster", "Unique"]
  p.abilities = ["Bulky", "Brawler (2)", "Fast Swimmer (3)", "Fear (-3)", "Limited Movement", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: morgraur, weapon: colossal_jaws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: morgraur, special_rule: serpentine)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: morgraur, special_rule: swallow_whole) { |psr| psr.position = 1 }

emissary_of_mother_hydra = Profile.find_or_create_by!(name: "Emissary of Mother Hydra") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 3; p.life_points = 30; p.will_points = 3; p.command_points = 0
  p.size = 75; p.ducats = 51; p.movement = 1; p.dexterity = 3; p.attack = 7; p.protection = 5; p.mind = 4
  p.keywords = ["Hero", "Monster", "Hydra", "Unique"]
  p.abilities = ["Bulky", "Fast Swimmer (3)", "Fear (-4)", "Limited Movement", "Vampiric Attack (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: emissary_of_mother_hydra, weapon: eldritch_maw) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: emissary_of_mother_hydra, special_rule: grasp_of_the_abyss) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: emissary_of_mother_hydra, special_rule: rip_apart)          { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: emissary_of_mother_hydra, special_rule: serpentine)         { |psr| psr.position = 2 }

# ── Henchmen — Emissary's Tentacles ─────────────────────────────────────────────

maw_tentacle = Profile.find_or_create_by!(name: "Maw Tentacle") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 5; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 2; p.dexterity = 4; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Brave", "Companion (Emissary of Mother Hydra)", "Engage", "Expert Grappler (2)", "Limited Movement", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: maw_tentacle, weapon: fanged_maw) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: maw_tentacle, special_rule: part_of_the_whole) { |psr| psr.position = 0 }

lash_tentacle = Profile.find_or_create_by!(name: "Lash Tentacle") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 5; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 2; p.dexterity = 4; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Brave", "Companion (Emissary of Mother Hydra)", "First Strike (2)", "Limited Movement", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: lash_tentacle, weapon: lashing_swipe) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: lash_tentacle, special_rule: part_of_the_whole) { |psr| psr.position = 0 }

dagger_tentacle = Profile.find_or_create_by!(name: "Dagger Tentacle") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 5; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 2; p.dexterity = 4; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Brave", "Companion (Emissary of Mother Hydra)", "Expert Marksman (1)", "Limited Movement", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: dagger_tentacle, weapon: rending_spine) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: dagger_tentacle, special_rule: part_of_the_whole) { |psr| psr.position = 0 }

thorn_tentacle = Profile.find_or_create_by!(name: "Thorn Tentacle") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 5; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 2; p.dexterity = 4; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Brave", "Companion (Emissary of Mother Hydra)", "Limited Movement", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: thorn_tentacle, weapon: thorned_grasp) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: thorn_tentacle, special_rule: part_of_the_whole) { |psr| psr.position = 0 }

# ── Heroes (continued) ──────────────────────────────────────────────────────────

drowned_nun = Profile.find_or_create_by!(name: "The Drowned Nun") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 4; p.command_points = 2
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique", "Discipline (Runes of Sovereignty, Fateweaving)"]
  p.abilities = ["Fast Swimmer (1)", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: drowned_nun, weapon: staff) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: drowned_nun, special_rule: dagonite_baptism)     { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: drowned_nun, special_rule: fanaticism_for_dagon) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: drowned_nun, special_rule: truth_of_dagon)       { |psr| psr.position = 2 }

brachyura = Profile.find_or_create_by!(name: "Brachyura") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 20; p.will_points = 1; p.command_points = 0
  p.size = 50; p.ducats = 18; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 7; p.mind = 2
  p.keywords = ["Hero", "Monster", "Feral"]
  p.abilities = ["Bulky", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: brachyura, weapon: crushing_claws) { |pw| pw.position = 0 }

caandru_eel = Profile.find_or_create_by!(name: "Caandru Eel") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 3; p.dexterity = 5; p.attack = 4; p.protection = 4; p.mind = 2
  p.keywords = ["Hero", "Monster", "Feral"]
  p.abilities = ["Expert Grappler (2)", "Fast Swimmer (2)", "Mindless", "Primitive", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: caandru_eel, weapon: mauling_talons) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: caandru_eel, special_rule: patient_hunter) { |psr| psr.position = 0 }

cult_enforcer = Profile.find_or_create_by!(name: "Cult Enforcer") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 1
  p.size = 40; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = ["Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: cult_enforcer, weapon: iron_mace) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cult_enforcer, special_rule: bolster_your_faith) { |psr| psr.position = 0 }

dagonite_priest = Profile.find_or_create_by!(name: "Dagonite Priest") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 12; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Discipline (Blood Rites, Wild Magic)"]
  p.abilities = ["Mage (2)", "Engage"]
end
ProfileWeapon.find_or_create_by!(profile: dagonite_priest, weapon: sacrificial_dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: dagonite_priest, special_rule: sacrifice) { |psr| psr.position = 0 }

demagogue = Profile.find_or_create_by!(name: "Demagogue") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 4
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero"]
  p.abilities = ["Brave", "Fear (0)"]
end
ProfileWeapon.find_or_create_by!(profile: demagogue, weapon: burning_brand) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: demagogue, special_rule: prove_yourselves_to_dagon) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: demagogue, special_rule: eldritch_incense)          { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: demagogue, special_rule: burned_flesh)              { |psr| psr.position = 2 }

handler = Profile.find_or_create_by!(name: "Handler") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero"]
  p.abilities = ["Brave", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: handler, weapon: herding_spear) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: handler, special_rule: herding)                { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: handler, special_rule: encouragement_handler)  { |psr| psr.position = 1 }

karcharos = Profile.find_or_create_by!(name: "Karcharos") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 15; p.will_points = 1; p.command_points = 0
  p.size = 50; p.ducats = 18; p.movement = 3; p.dexterity = 4; p.attack = 5; p.protection = 4; p.mind = 2
  p.keywords = ["Hero", "Monster", "Feral"]
  p.abilities = ["Fast Swimmer (3)", "Fear (-2)", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: karcharos, weapon: mighty_jaws) { |pw| pw.position = 0 }

krakenhost = Profile.find_or_create_by!(name: "Krakenhost") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 17; p.movement = 3; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero"]
  p.abilities = ["Companion (Hydra)", "Expert Grappler (2)", "First Strike (1)", "Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: krakenhost, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: krakenhost, special_rule: spawn_3lp)     { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: krakenhost, special_rule: living_vessel) { |psr| psr.position = 1 }

mature_kraken = Profile.find_or_create_by!(name: "Mature Kraken") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 22; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 24; p.movement = 4; p.dexterity = 3; p.attack = 5; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Monster", "Hydra"]
  p.abilities = ["Engage", "Expert Grappler (2)", "Fear (-1)", "Vampiric Attack (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: mature_kraken, weapon: barbed_tentacles) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: mature_kraken, special_rule: climbing_suckers) { |psr| psr.position = 0 }

paliaa = Profile.find_or_create_by!(name: "Paliaa") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 13; p.will_points = 5; p.command_points = 2
  p.size = 40; p.ducats = 19; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Monster", "Discipline (Runes of Sovereignty)"]
  p.abilities = ["Fast Swimmer (2)", "Mage (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: paliaa, weapon: claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: paliaa, special_rule: gift_of_the_elder_gods) { |psr| psr.position = 0 }

raadru = Profile.find_or_create_by!(name: "Raadru") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 20; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 20; p.movement = 3; p.dexterity = 4; p.attack = 5; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Monster"]
  p.abilities = ["Fast Swimmer (2)", "Fear (0)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: raadru, weapon: webbed_fists) { |pw| pw.position = 0 }

# ── Special Rules (second half) ─────────────────────────────────────────────────

dimensional_pool = SpecialRule.find_or_create_by!(name: "Dimensional Pool") do |r|
  r.description = "After resolving an attack with the Water Portal, leave the blast marker in place. Until the end of the round the space beneath counts as water."
end
gusher = SpecialRule.find_or_create_by!(name: "Gusher") do |r|
  r.description = "This character can make Drown actions against opponents no matter whether they're in water or not. Additionally, it gains +2 ATTACK when making a Drown action."
end
mucus = SpecialRule.find_or_create_by!(name: "Mucus") do |r|
  r.description = "This character gains +4 DEXTERITY for any Combat actions (including Attacks of Opportunity) if the attacker is within 3\". Additionally, any enemy character within 3\" of this character suffers -1 to their MOVEMENT and DEXTERITY."
end
hypnotic_song = SpecialRule.find_or_create_by!(name: "Hypnotic Song") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any enemy characters within 6\" of this character have -2 MIND."
end
drag_to_the_depths = SpecialRule.find_or_create_by!(name: "Drag to the Depths") do |r|
  r.description = "If a Combat action with Mutated Limbs results in an enemy character losing Life Points, move that character into base contact with this character, ignoring attacks of opportunity."
end
leaper = SpecialRule.find_or_create_by!(name: "Leaper") do |r|
  r.description = "When this character makes a successful Jump action, add 2\" to the movement distance."
end
barbed_tongue = SpecialRule.find_or_create_by!(name: "Barbed Tongue") do |r|
  r.description = "The Tongue Harpoon's Knockback moves the target directly towards this character rather than away."
end
feeder = SpecialRule.find_or_create_by!(name: "Feeder") do |r|
  r.description = "This character's Vampiric Attack special rule activates even if it isn't in base contact with its target."
end
bait = SpecialRule.find_or_create_by!(name: "Bait") do |r|
  r.description = "Friendly characters may attack this character as if it were an enemy. If a friendly character kills this character, it loses the Mindless rule for the rest of the game."
end
piercing_wail = SpecialRule.find_or_create_by!(name: "Piercing Wail") do |r|
  r.description = "Any enemy characters within 6\" of this character have -1 DEXTERITY."
end
unsightly = SpecialRule.find_or_create_by!(name: "Unsightly") do |r|
  r.description = "This character can be deployed anywhere on the board at ground level, at least 6\" away from any enemy characters or objectives."
end
corrupted_relic = SpecialRule.find_or_create_by!(name: "Corrupted Relic") do |r|
  r.description = "Whenever an enemy character within 6\" and Line of Sight of this character makes a Basic roll, they must re-roll a single Ace in that roll."
end
climber = SpecialRule.find_or_create_by!(name: "Climber") do |r|
  r.description = "This character always counts as rolling at least one Ace when making Climb rolls."
end
one_mind = SpecialRule.find_or_create_by!(name: "One Mind") do |r|
  r.description = "When this character makes a Combat action, it gains +1 to its ATTACK for every other Infant Kraken in base contact with the target."
end
writhe_inside = SpecialRule.find_or_create_by!(name: "Writhe Inside") do |r|
  r.description = "When this character successfully damages an enemy character (after its Protection roll), you may remove this character from the game as if it were killed. If you do, place it on the damaged character's card. For the rest of the game, that character always counts as having a Stun counter."
end
unassuming = SpecialRule.find_or_create_by!(name: "Unassuming") do |r|
  r.description = "If this character disengages successfully and does not use the action to charge another enemy character, make a 0AP Attack of Opportunity with this character before moving."
end
surrogate = SpecialRule.find_or_create_by!(name: "Surrogate") do |r|
  r.description = "Friendly characters with the Hydra keyword within 6\" and line of sight may use this character's Will Points as if they were their own."
end
kraken_nurse = SpecialRule.find_or_create_by!(name: "Kraken Nurse") do |r|
  r.description = "When you place a new Infant Kraken in line of sight of this character, this character recovers 1 lost Will Point."
end
feast_for_dagon = SpecialRule.find_or_create_by!(name: "Feast for Dagon") do |r|
  r.description = "If this character ends its turn in base contact with a friendly character with the Monster keyword, you may choose to remove it from play as a casualty. The Monster character immediately replenishes 5 Life Points."
end

# ── Weapons (second half) ─────────────────────────────────────────────────────

water_portal        = Weapon.find_or_create_by!(name: "Water Portal")        { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic", "Blast", "Reload (1)", "Stun"] }
sticky_burst        = Weapon.find_or_create_by!(name: "Sticky Burst")        { |w| w.range = 6;  w.evasion = 2;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun", "Reload (2)"] }
grasping_jaws       = Weapon.find_or_create_by!(name: "Grasping Jaws")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = [] }
razor_maw           = Weapon.find_or_create_by!(name: "Razor Maw")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -2; w.abilities = ["Aquatic"] }
mutated_limbs       = Weapon.find_or_create_by!(name: "Mutated Limbs")       { |w| w.range = 4;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
weak_claws          = Weapon.find_or_create_by!(name: "Weak Claws")          { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
tongue_harpoon      = Weapon.find_or_create_by!(name: "Tongue Harpoon")      { |w| w.range = 12; w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic", "Knockback", "Reload (1)"] }
crusted_fist        = Weapon.find_or_create_by!(name: "Crusted Fist")        { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Knockback", "Stun"] }
khopesh_daggers     = Weapon.find_or_create_by!(name: "Khopesh Daggers")     { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
encrusted_hands     = Weapon.find_or_create_by!(name: "Encrusted Hands")     { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
wave_blade_knife    = Weapon.find_or_create_by!(name: "Wave-blade Knife")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
sodden_longsword    = Weapon.find_or_create_by!(name: "Sodden Longsword")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = ["Two-handed"] }
heavy_tentacles     = Weapon.find_or_create_by!(name: "Heavy Tentacles")     { |w| w.range = 1;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Knockback"] }
gaping_maw          = Weapon.find_or_create_by!(name: "Gaping Maw")          { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
encrusted_weapon    = Weapon.find_or_create_by!(name: "Encrusted Weapon")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
dementing_tentacles = Weapon.find_or_create_by!(name: "Dementing Tentacles") { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic", "Stun"] }
claws_ugdru         = Weapon.find_or_create_by!(name: "Claws", damage: 1)    { |w| w.range = 0;  w.evasion = 0;  w.penetration = -1; w.abilities = ["Aquatic"] }
flint_dagger        = Weapon.find_or_create_by!(name: "Flint Dagger")        { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }

# ── Heroes (second half) ──────────────────────────────────────────────────────

salaacia = Profile.find_or_create_by!(name: "Salaacia") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 17; p.will_points = 4; p.command_points = 0
  p.size = 40; p.ducats = 16; p.movement = 3; p.dexterity = 3; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Feral"]
  p.abilities = ["Fast Swimmer (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: salaacia, weapon: water_portal) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: salaacia, special_rule: dimensional_pool) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: salaacia, special_rule: gusher)           { |psr| psr.position = 1 }

secreting_myxin = Profile.find_or_create_by!(name: "Secreting Myxin") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 18; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 23; p.movement = 4; p.dexterity = 2; p.attack = 4; p.protection = 1; p.mind = 1
  p.keywords = ["Hero", "Monster", "Feral"]
  p.abilities = ["Parry (3)", "Mindless", "Slippery", "Vampiric Attack (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: secreting_myxin, weapon: sticky_burst)  { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: secreting_myxin, weapon: grasping_jaws) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: secreting_myxin, special_rule: mucus) { |psr| psr.position = 0 }

sirena = Profile.find_or_create_by!(name: "Sirena") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 12; p.will_points = 5; p.command_points = 1
  p.size = 30; p.ducats = 18; p.movement = 3; p.dexterity = 5; p.attack = 3; p.protection = 1; p.mind = 5
  p.keywords = ["Hero", "Monster", "Hydra", "Discipline (Blood Rites, Runes of Sovereignty)"]
  p.abilities = ["Engage", "Fast Swimmer (4)", "Mage (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: sirena, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sirena, special_rule: hypnotic_song) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sirena, special_rule: dragging_down) { |psr| psr.position = 1 }

tainted_maw = Profile.find_or_create_by!(name: "Tainted Maw") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 18; p.will_points = 1; p.command_points = 0
  p.size = 50; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Hero", "Feral"]
  p.abilities = ["Expert Grappler (1)", "Fast Swimmer (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: tainted_maw, weapon: razor_maw)     { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: tainted_maw, weapon: mutated_limbs) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: tainted_maw, special_rule: drag_to_the_depths) { |psr| psr.position = 0 }

# ── Henchmen (second half) ──────────────────────────────────────────────────────

advanced_hybrid = Profile.find_or_create_by!(name: "Advanced Hybrid") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 1; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Acrobatic (2)", "First Strike (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: advanced_hybrid, weapon: weak_claws) { |pw| pw.position = 0 }

aglaope = Profile.find_or_create_by!(name: "Aglaope") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 5; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 5; p.attack = 2; p.protection = 1; p.mind = 4
  p.keywords = ["Henchman", "Monster", "Discipline (Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (1)", "Fast Swimmer (2)", "Mage (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: aglaope, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: aglaope, special_rule: dragging_down) { |psr| psr.position = 0 }

bounding_telebine = Profile.find_or_create_by!(name: "Bounding Telebine") do |p|
  p.version = "2.2.1"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 9; p.movement = 3; p.dexterity = 5; p.attack = 3; p.protection = 1; p.mind = 2
  p.keywords = ["Henchman", "Feral"]
  p.abilities = ["Primitive", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: bounding_telebine, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: bounding_telebine, special_rule: leaper) { |psr| psr.position = 0 }

bulbous_toad = Profile.find_or_create_by!(name: "Bulbous Toad") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 14; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 13; p.movement = 2; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman", "Monster", "Feral"]
  p.abilities = ["Fast Swimmer (2)", "Mindless", "Primitive", "Vampiric Attack (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: bulbous_toad, weapon: tongue_harpoon) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: bulbous_toad, special_rule: barbed_tongue) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: bulbous_toad, special_rule: feeder)        { |psr| psr.position = 1 }

crybaby = Profile.find_or_create_by!(name: "Crybaby") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 4; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 6; p.dexterity = 4; p.attack = 2; p.protection = 0; p.mind = 1
  p.keywords = ["Henchman", "Feral"]
  p.abilities = ["Concealment (+2)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: crybaby, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: crybaby, special_rule: bait)          { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: crybaby, special_rule: piercing_wail) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: crybaby, special_rule: unsightly)     { |psr| psr.position = 2 }

cymothoan_crusher = Profile.find_or_create_by!(name: "Cymothoan Crusher") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 17; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 17; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 5; p.mind = 1
  p.keywords = ["Henchman", "Feral"]
  p.abilities = ["Bulky", "First Strike (3)", "Primitive", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: cymothoan_crusher, weapon: crusted_fist) { |pw| pw.position = 0 }

dagon_officiant = Profile.find_or_create_by!(name: "Dagon Officiant") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["Henchman"]
  p.abilities = ["Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: dagon_officiant, weapon: khopesh_daggers) { |pw| pw.position = 0 }

dagonite_page = Profile.find_or_create_by!(name: "Dagonite Page") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: dagonite_page, weapon: encrusted_hands) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: dagonite_page, special_rule: corrupted_relic) { |psr| psr.position = 0 }

dagonite_zealot = Profile.find_or_create_by!(name: "Dagonite Zealot") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 4; p.dexterity = 6; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Aerial Attack", "Expert Offence (1)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: dagonite_zealot, weapon: wave_blade_knife) { |pw| pw.position = 0 }

encrusted_squire = Profile.find_or_create_by!(name: "Encrusted Squire") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Bodyguard (Leader, Feral)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: encrusted_squire, weapon: sodden_longsword) { |pw| pw.position = 0 }

half_breed = Profile.find_or_create_by!(name: "Half-Breed") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 12; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 16; p.movement = 3; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Berserk", "Companion (Hydra)", "Expert Grappler (2)", "Fast Swimmer (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: half_breed, weapon: heavy_tentacles) { |pw| pw.position = 0 }

hellhound = Profile.find_or_create_by!(name: "Hellhound") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Monster", "Feral"]
  p.abilities = ["First Strike (1)", "Primitive", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: hellhound, weapon: gaping_maw) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: hellhound, special_rule: climber) { |psr| psr.position = 0 }

hybrid = Profile.find_or_create_by!(name: "Hybrid") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: hybrid, weapon: encrusted_weapon) { |pw| pw.position = 0 }

infant_kraken = Profile.find_or_create_by!(name: "Infant Kraken") do |p|
  p.version = "2.3.1"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 5; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 4; p.dexterity = 5; p.attack = 2; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman", "Hydra"]
  p.abilities = ["Concealment (2)", "Primitive", "Water Creature", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: infant_kraken, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: infant_kraken, special_rule: one_mind)      { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: infant_kraken, special_rule: writhe_inside) { |psr| psr.position = 1 }

lesser_rhyll = Profile.find_or_create_by!(name: "Lesser Rhyll") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["Henchman", "Monster"]
  p.abilities = ["Fast Swimmer (1)", "Fear (0)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: lesser_rhyll, weapon: dementing_tentacles) { |pw| pw.position = 0 }

lesser_ugdru = Profile.find_or_create_by!(name: "Lesser Ugdru") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 13; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 14; p.movement = 3; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["Henchman", "Monster"]
  p.abilities = ["Fast Swimmer (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: lesser_ugdru, weapon: claws_ugdru) { |pw| pw.position = 0 }

slave = Profile.find_or_create_by!(name: "Slave") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: slave, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: slave, special_rule: feast_for_dagon) { |psr| psr.position = 0 }

urchin = Profile.find_or_create_by!(name: "Urchin") do |p|
  p.version = "2.2.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 8; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 1; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Mindless", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: urchin, weapon: flint_dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: urchin, special_rule: unassuming) { |psr| psr.position = 0 }

wet_nurse = Profile.find_or_create_by!(name: "Wet Nurse") do |p|
  p.version = "2.3.0"; p.faction = "rashaar"
  p.action_points = 2; p.life_points = 10; p.will_points = 3; p.command_points = 2
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Hydra)", "Concealment (1)"]
end
ProfileWeapon.find_or_create_by!(profile: wet_nurse, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wet_nurse, special_rule: surrogate)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wet_nurse, special_rule: kraken_nurse) { |psr| psr.position = 1 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Pages 15, 30, 34, 36, 38, 42, 43, 45, 46, 47 produced _a/_b variants; _a is used.
{
  "The Flame That Burns Underwater" => "p02.png",
  "Magi-Rashaar"                   => ["p03.png", 6, -1, 95, false],
  "Paartul Matriarch"              => "p04.png",
  "Sir Tiburcio"                   => "p05.png",
  "Thalidraur"                     => ["p06.png", -27, 31, 115, false],
  "Voice of Dagon"                 => ["p07.png", 27, -14, 90, false],
  "Morgraur"                       => ["p08.png", -3, -5, 95, false],
  "Emissary of Mother Hydra"       => ["p09.png", -16, -15, 90, false],
  "Maw Tentacle"                   => ["p10.png", 33, 3, 70, false],
  "Lash Tentacle"                  => ["p11.png", 29, -22, 70, false],
  "Dagger Tentacle"                => ["p12.png", 21, -12, 80, false],
  "Thorn Tentacle"                 => ["p13.png", 38, -13, 70, false],
  "The Drowned Nun"                => ["p14.png", 18, -30, 90, false],
  "Brachyura"                      => ["p15_a.png", 13, -7, 95, false],
  "Caandru Eel"                    => "p16.png",
  "Cult Enforcer"                  => ["p17.png", 2, -11, 90, false],
  "Dagonite Priest"                => ["p18.png", 2, -4, 100, false],
  "Demagogue"                      => ["p19.png", 9, -6, 105, false],
  "Handler"                        => ["p20.png", -8, -34, 115, true],
  "Karcharos"                      => ["p21.png", 4, -23, 90, false],
  "Krakenhost"                     => ["p22.png", 14, -10, 80, false],
  "Mature Kraken"                  => ["p23.png", 5, -9, 90, true],
  "Paliaa"                         => ["p24.png", 28, -23, 75, false],
  "Raadru"                         => "p25.png",
  "Salaacia"                       => ["p26.png", -3, -8, 95, false],
  "Secreting Myxin"                => ["p27.png", 6, -9, 110, false],
  "Sirena"                         => ["p28.png", 12, -11, 95, false],
  "Tainted Maw"                    => "p29.png",
  "Advanced Hybrid"                => ["p30_a.png", 8, -15, 95, false],
  "Aglaope"                        => ["p31.png", 34, -12, 60, false],
  "Bounding Telebine"              => "p32.png",
  "Bulbous Toad"                   => ["p33.png", 11, 5, 100, false],
  "Crybaby"                        => ["p34_a.png", -5, -53, 65, false],
  "Cymothoan Crusher"              => "p35.png",
  "Dagon Officiant"                => ["p36_a.png", 7, -14, 85, false],
  "Dagonite Page"                  => ["p37.png", 2, 6, 135, false],
  "Dagonite Zealot"                => ["p38_a.png", 11, -19, 95, true],
  "Encrusted Squire"               => ["p39.png", 2, 6, 115, false],
  "Half-Breed"                     => ["p40.png", -17, 15, 105, false],
  "Hellhound"                      => ["p41.png", 24, -18, 85, false],
  "Hybrid"                         => ["p42_a.png", 7, -21, 90, false],
  "Infant Kraken"                  => ["p43_a.png", 10, -11, 90, false],
  "Lesser Rhyll"                   => ["p44.png", 30, -13, 75, false],
  "Lesser Ugdru"                   => ["p45_a.png", -9, -48, 80, false],
  "Slave"                          => ["p46_a.png", 43, -24, 70, false],
  "Urchin"                         => ["p47_a.png", 6, -27, 90, false],
  "Wet Nurse"                      => ["p48.png", 42, -18, 75, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "rashaar", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Brachyura"      => ["p15_b.png", 6, -24, 75, false],
  "Advanced Hybrid" => ["p30_b.png", 10, -21, 70, false],
  "Crybaby"        => ["p34_b.png", 23, -36, 80, false],
  "Dagon Officiant" => ["p36_b.png", 32, -13, 75, false],
  "Dagonite Zealot" => ["p38_b.png", 12, -7, 95, false],
  "Hybrid"         => ["p42_b.png", 31, -27, 75, false],
  "Infant Kraken"  => "p43_b.png",
  "Lesser Ugdru"   => ["p45_b.png", 7, -18, 85, true],
  "Slave"          => ["p46_b.png", 49, -31, 70, false],
  "Urchin"         => ["p47_b.png", 21, -21, 80, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "rashaar", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

# ── Link CardReferences to Profiles ───────────────────────────────────────────
profile_map = Profile.where(faction: "rashaar").each_with_object({}) { |p, h| h[p.name] = p.id }
CardReference.where(faction: "rashaar").find_each do |cr|
  base_name = cr.name.sub(/ \([AB]\)\z/, "")
  profile_id = profile_map[base_name]
  cr.update_columns(profile_id: profile_id) if profile_id && cr.profile_id != profile_id
end
cr_count = CardReference.where(faction: "rashaar").count
p_count  = Profile.where(faction: "rashaar").count
puts "Seeded Rashaar: #{cr_count} card references, #{p_count} profiles."
