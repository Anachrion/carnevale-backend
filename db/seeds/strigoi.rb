# ── Card References ────────────────────────────────────────────────────────────
card_ref_data = [
  { name: "Vlad Dracula",        identifier: "strigoi-vlad-dracula",        cost: 27 },
  { name: "Blood Crone",         identifier: "strigoi-blood-crone",         cost: 18 },
  { name: "Noble Strigoi",       identifier: "strigoi-noble-strigoi",       cost: 21 },
  { name: "Stryha Crone",        identifier: "strigoi-stryha-crone",        cost: 22 },
  { name: "Wallachian Hospodar", identifier: "strigoi-wallachian-hospodar", cost: 21 },
  { name: "Ceres",               identifier: "strigoi-ceres",               cost: 19 },
  { name: "Cibele",              identifier: "strigoi-cibele",              cost: 19 },
  { name: "Miriam",              identifier: "strigoi-miriam",              cost: 19 },
  { name: "Monstrous Stryx",     identifier: "strigoi-monstrous-stryx",     cost: 40 },
  { name: "Aquatic Strigoi",     identifier: "strigoi-aquatic-strigoi",     cost: 14 },
  { name: "Cetean Upior",        identifier: "strigoi-cetean-upior",        cost: 21 },
  { name: "Highborn Servant",    identifier: "strigoi-highborn-servant",    cost: 13 },
  { name: "Hulking Moroi",       identifier: "strigoi-hulking-moroi",       cost: 14 },
  { name: "Leech",               identifier: "strigoi-leech",               cost: 12 },
  { name: "Moon Eater",          identifier: "strigoi-moon-eater",          cost: 23 },
  { name: "Reaper",              identifier: "strigoi-reaper",              cost: 13 },
  { name: "Seer",                identifier: "strigoi-seer",                cost: 15 },
  { name: "Spatar",              identifier: "strigoi-spatar",              cost: 16 },
  { name: "Strige",              identifier: "strigoi-strige",              cost: 14 },
  { name: "Strigoi Jude",        identifier: "strigoi-strigoi-jude",        cost: 18 },
  { name: "Strigoi Priest",      identifier: "strigoi-strigoi-priest",      cost: 14 },
  { name: "Targoveti",           identifier: "strigoi-targoveti-a",         cost: 10 },
  { name: "Targoveti",           identifier: "strigoi-targoveti-b",         cost: 10 },
  { name: "Thrall",              identifier: "strigoi-thrall-a",            cost:  9 },
  { name: "Thrall",              identifier: "strigoi-thrall-b",            cost:  9 },
  { name: "Strigoi Sluger",      identifier: "strigoi-strigoi-sluger",      cost: 18 },
  { name: "Strzyga",             identifier: "strigoi-strzyga",             cost: 18 },
  { name: "Tarot Reader",        identifier: "strigoi-tarot-reader",        cost: 16 },
  { name: "Varcolac",            identifier: "strigoi-varcolac",            cost: 17 },
  { name: "Wallachian Impaler",  identifier: "strigoi-wallachian-impaler",  cost: 18 },
  { name: "Zoryi",               identifier: "strigoi-zoryi",               cost: 19 },
  { name: "Al Naibii",           identifier: "strigoi-al-naibii",           cost:  9 },
  { name: "Common Strigoi",      identifier: "strigoi-common-strigoi-a",    cost: 13 },
  { name: "Common Strigoi",      identifier: "strigoi-common-strigoi-b",    cost: 13 },
  { name: "Ferryman",            identifier: "strigoi-ferryman-a",          cost:  9 },
  { name: "Ferryman",            identifier: "strigoi-ferryman-b",          cost:  9 },
  { name: "Giurgiu Guard",       identifier: "strigoi-giurgiu-guard-a",     cost: 13 },
  { name: "Giurgiu Guard",       identifier: "strigoi-giurgiu-guard-b",     cost: 13 },
  { name: "Harpy",               identifier: "strigoi-harpy-a",             cost:  6 },
  { name: "Harpy",               identifier: "strigoi-harpy-b",             cost:  6 },
  { name: "Newborn Strigoi",     identifier: "strigoi-newborn-strigoi",     cost:  8 },
  { name: "Nosferatu",           identifier: "strigoi-nosferatu-a",         cost: 13 },
  { name: "Nosferatu",           identifier: "strigoi-nosferatu-b",         cost: 13 },
  { name: "Romani",              identifier: "strigoi-romani-a",            cost:  9 },
  { name: "Romani",              identifier: "strigoi-romani-b",            cost:  9 },
  { name: "Rotter",              identifier: "strigoi-rotter-a",            cost: 12 },
  { name: "Rotter",              identifier: "strigoi-rotter-b",            cost: 12 },
  { name: "Sinker",              identifier: "strigoi-sinker-a",            cost: 10 },
  { name: "Sinker",              identifier: "strigoi-sinker-b",            cost: 10 },
  { name: "Starved Dhampir",     identifier: "strigoi-starved-dhampir",     cost:  7 },
  { name: "Poenari Scout",       identifier: "strigoi-poenari-scout",       cost: 12 },
]


# ── Special Rules ──────────────────────────────────────────────────────────────

transformation = SpecialRule.find_or_create_by!(name: "Transformation") do |r|
  r.description = "PULSE Command Ability. Remove this character and place it anywhere on solid ground within 8\", at least 3\" away from any enemy characters. This ability cannot be used while in base contact with an enemy character."
end
master_bloodline = SpecialRule.find_or_create_by!(name: "Master Bloodline") do |r|
  r.description = "All friendly characters with the Vampire keyword in line of sight to this character gain Bodyguard (Vlad Dracula) and Companion (Vlad Dracula)."
end
connoisseur = SpecialRule.find_or_create_by!(name: "Connoisseur") do |r|
  r.description = "Vlad will not drink the blood of just anyone. When attacking a character with the Hero keyword, he gains Vampiric Attack (1). When attacking a character with the Leader keyword, he gains Vampiric Attack (3)."
end
clairvoyancy = SpecialRule.find_or_create_by!(name: "Clairvoyancy") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 6\" may re-roll 1 dice on any of their rolls. Note that this does not include the Destiny dice!"
end
major_arcana = SpecialRule.find_or_create_by!(name: "Major Arcana") do |r|
  r.description = "When picking spells, this character always knows all Cantrips from all Disciplines (even those she doesn't have access to)."
end
minor_incantata = SpecialRule.find_or_create_by!(name: "Minor Incantata") do |r|
  r.description = "This character may cast a Cantrip for 0AP once per character turn. All the standard rules for casting spells apply."
end
blood_frenzy = SpecialRule.find_or_create_by!(name: "Blood Frenzy") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters with the Vampire keyword within Line of Sight increase their Vampiric Attack by 1 to a maximum of 2."
end
bloodline = SpecialRule.find_or_create_by!(name: "Bloodline") do |r|
  r.description = "All friendly characters with the Vampire keyword in line of sight to this character gain Companion (Noble Strigoi)."
end
sanguine_sabotage = SpecialRule.find_or_create_by!(name: "Sanguine Sabotage") do |r|
  r.description = "The Noble Strigoi has infiltrated the opponent's gang to take them down from within. Whenever an enemy character uses a Command within 6\" of this character, roll a dice. On a 7+ the Command costs an extra Command Point if possible."
end
natural_camouflage = SpecialRule.find_or_create_by!(name: "Natural Camouflage") do |r|
  r.description = "PULSE Command Ability. Pick one friendly character within 6\". That character gains Concealment (+2) until the end of the game. A character can only be affected by this Command Ability once."
end
carrion = SpecialRule.find_or_create_by!(name: "Carrion") do |r|
  r.description = "Before deployment, choose 3 friendly characters. They gain Infiltration."
end
defensive_lines = SpecialRule.find_or_create_by!(name: "Defensive Lines") do |r|
  r.description = "PULSE Command Ability. Until the end of the round, all other friendly characters within 3\" gain Universal Shielding (2)."
end
warlord = SpecialRule.find_or_create_by!(name: "Warlord") do |r|
  r.description = "Friendly characters with the Soldier keyword may use this character's MIND instead of their own while they are in Line of Sight of this character."
end
full_plate = SpecialRule.find_or_create_by!(name: "Full Plate") do |r|
  r.description = "If this character ever enters water, it receives a Stunned counter which is only removed if it ends its turn out of water."
end
procession_of_brides = SpecialRule.find_or_create_by!(name: "Procession of Brides") do |r|
  r.description = "While building your Gang, if it contains Vlad Dracula, this character counts as having the Henchman keyword instead of the Hero keyword for the purposes of Frequency."
end
romani_fury = SpecialRule.find_or_create_by!(name: "Romani Fury") do |r|
  r.description = "PULSE Command Ability. Every friendly character with the Bride keyword gains Expert Offence (3) until the end of the round."
end
african_bewitching = SpecialRule.find_or_create_by!(name: "African Bewitching") do |r|
  r.description = "PULSE Command Ability. Every friendly character with the Bride keyword gains Stun on their weapons until the end of the round."
end
eastern_swiftness = SpecialRule.find_or_create_by!(name: "Eastern Swiftness") do |r|
  r.description = "PULSE Command Ability. Every friendly character with the Bride keyword gains 1 AP until the end of the round."
end
sisters_of_gelo = SpecialRule.find_or_create_by!(name: "Sisters of Gélo") do |r|
  r.description = "This character replenishes 1 Command Point at the start of each character turn if it has line of sight to any other friendly character with the Bride keyword."
end
aerial_aggression = SpecialRule.find_or_create_by!(name: "Aerial Aggression") do |r|
  r.description = "When this character moves into base contact with an enemy character that is either 3\" above or 3\" below it at the start of the action, that enemy character skips their Protection roll for this character's Attack of Opportunity."
end
serpentine = SpecialRule.find_or_create_by!(name: "Serpentine") do |r|
  r.description = "This character is able to move through spaces smaller than its base to a minimum of 2\". It must be able to fit where it ends its turn."
end
rip_and_tear = SpecialRule.find_or_create_by!(name: "Rip and Tear") do |r|
  r.description = "When this character makes a Combat action with Monstrous Claws against an enemy character with full Life Points, for the rest of this character's activation, it may re-roll any failed dice for Combat actions against that enemy character."
end
hydrodynamic = SpecialRule.find_or_create_by!(name: "Hydrodynamic") do |r|
  r.description = "This character increases its DEXTERITY to 5 while in water."
end
bankroll = SpecialRule.find_or_create_by!(name: "Bankroll") do |r|
  r.description = "For every character with this ability in your gang at the start of the round, select a different piece of Equipment that you have already used. You may use this piece of Equipment once more this round."
end
brain_leech = SpecialRule.find_or_create_by!(name: "Brain Leech") do |r|
  r.description = "When this character replenishes Life Points due to the Vampiric Attack ability, the target character lowers any abilities with a number down by 1 until the end of the game, to a minimum of 0. For example Acrobatic (3) becomes Acrobatic (2)."
end
lunar_might = SpecialRule.find_or_create_by!(name: "Lunar Might") do |r|
  r.description = "During deployment let your opponent know when the moon will be brightest. Choose either the first 3 rounds, or the remaining rounds. When the moon is brightest, all characters with this rule increase their MOVEMENT, DEXTERITY, and ATTACK by 1."
end
devourer_of_will = SpecialRule.find_or_create_by!(name: "Devourer of Will") do |r|
  r.description = "When this character kills an enemy character, it gains their starting Will Points. This is cumulative and can take this character above its starting Will Points."
end
soothsaying = SpecialRule.find_or_create_by!(name: "Soothsaying") do |r|
  r.description = "PULSE Command Ability. For every enemy character in line of sight to this character, add a re-roll to your Soothsaying Pool. Until the end of the round, any friendly character may use these re-rolls on any roll this round - one re-roll per dice."
end
premonition = SpecialRule.find_or_create_by!(name: "Premonition") do |r|
  r.description = "Whenever rolling dice for this character, you may re-roll the Destiny Dice."
end

# ── Weapons ───────────────────────────────────────────────────────────────────

wallachian_halberd = Weapon.find_or_create_by!(name: "Wallachian Halberd") { |w| w.range = 2; w.evasion = 0;  w.damage = 1;  w.penetration = -2; w.abilities = ["Two-handed"] }
unarmed            = Weapon.find_or_create_by!(name: "Unarmed")            { |w| w.range = 0; w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }
fangs              = Weapon.find_or_create_by!(name: "Fangs")              { |w| w.range = 0; w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
talons             = Weapon.find_or_create_by!(name: "Talons")             { |w| w.range = 0; w.evasion = 0;  w.damage = 1;  w.penetration = -3; w.abilities = [] }
longsword          = Weapon.find_or_create_by!(name: "Longsword")          { |w| w.range = 0; w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
monstrous_claws    = Weapon.find_or_create_by!(name: "Monstrous Claws")    { |w| w.range = 0; w.evasion = 0;  w.damage = 2;  w.penetration = -2; w.abilities = [] }
baleful_screech    = Weapon.find_or_create_by!(name: "Baleful Screech")    { |w| w.range = 6; w.evasion = -2; w.damage = 0;  w.penetration = 0;  w.abilities = ["Blast", "Harmless", "Stun"] }
webbed_talons      = Weapon.find_or_create_by!(name: "Webbed Talons")      { |w| w.range = 0; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Aquatic"] }
distended_jaws     = Weapon.find_or_create_by!(name: "Distended Jaws")     { |w| w.range = 0; w.evasion = 1;  w.damage = 0;  w.penetration = -3; w.abilities = [] }
pistol             = Weapon.find_or_create_by!(name: "Pistol")             { |w| w.range = 8; w.evasion = 1;  w.damage = 0;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
sword              = Weapon.find_or_create_by!(name: "Sword")              { |w| w.range = 0; w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
clawed_hands       = Weapon.find_or_create_by!(name: "Clawed Hands")       { |w| w.range = 0; w.evasion = 0;  w.damage = 1;  w.penetration = -2; w.abilities = [] }
a_thousand_teeth   = Weapon.find_or_create_by!(name: "A Thousand Teeth")   { |w| w.range = 0; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Aquatic"] }
brutal_claws       = Weapon.find_or_create_by!(name: "Brutal Claws")       { |w| w.range = 0; w.evasion = -1; w.damage = 0;  w.penetration = -3; w.abilities = [] }
staff              = Weapon.find_or_create_by!(name: "Staff")              { |w| w.range = 1; w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
flanged_mace       = Weapon.find_or_create_by!(name: "Flanged Mace")       { |w| w.range = 0; w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Knockback"] }
coustille          = Weapon.find_or_create_by!(name: "Coustille")          { |w| w.range = 0; w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }

# ── Leaders ───────────────────────────────────────────────────────────────────

vlad_dracula = Profile.find_or_create_by!(name: "Vlad Dracula") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 15; p.will_points = 0; p.command_points = 5
  p.size = 30; p.ducats = 27; p.movement = 4; p.dexterity = 5; p.attack = 5; p.protection = 5; p.mind = 5
  p.keywords = ["Leader", "Unique", "Vampire"]
  p.abilities = ["Expert Offence (2)", "Expert Protection (2)", "Frenzied"]
end
ProfileWeapon.find_or_create_by!(profile: vlad_dracula, weapon: wallachian_halberd) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: vlad_dracula, special_rule: transformation)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: vlad_dracula, special_rule: master_bloodline) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: vlad_dracula, special_rule: connoisseur)      { |psr| psr.position = 2 }

blood_crone = Profile.find_or_create_by!(name: "Blood Crone") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 13; p.will_points = 5; p.command_points = 3
  p.size = 30; p.ducats = 18; p.movement = 3; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 5
  p.keywords = ["Leader", "Discipline (Runes of Sovereignty, Blood Rites, Fateweaving)"]
  p.abilities = ["Mage (3)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: blood_crone, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_crone, special_rule: clairvoyancy)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_crone, special_rule: major_arcana)    { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: blood_crone, special_rule: minor_incantata) { |psr| psr.position = 2 }

noble_strigoi = Profile.find_or_create_by!(name: "Noble Strigoi") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 13; p.will_points = 0; p.command_points = 4
  p.size = 30; p.ducats = 21; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Leader", "Vampire"]
  p.abilities = ["Expert Offence (3)", "Frenzied", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: noble_strigoi, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: noble_strigoi, special_rule: blood_frenzy)      { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: noble_strigoi, special_rule: bloodline)         { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: noble_strigoi, special_rule: sanguine_sabotage) { |psr| psr.position = 2 }

stryha_crone = Profile.find_or_create_by!(name: "Stryha Crone") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 12; p.will_points = 0; p.command_points = 3
  p.size = 30; p.ducats = 22; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 1; p.mind = 3
  p.keywords = ["Leader", "Vampire"]
  p.abilities = ["Concealment (+2)", "Flight", "Frenzied", "Infiltration", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: stryha_crone, weapon: talons) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: stryha_crone, special_rule: natural_camouflage) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: stryha_crone, special_rule: carrion)            { |psr| psr.position = 1 }

wallachian_hospodar = Profile.find_or_create_by!(name: "Wallachian Hospodar") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 14; p.will_points = 0; p.command_points = 3
  p.size = 30; p.ducats = 21; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 6; p.mind = 4
  p.keywords = ["Leader", "Vampire", "Soldier"]
  p.abilities = ["Frenzied", "Universal Shielding (3)", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: wallachian_hospodar, weapon: longsword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wallachian_hospodar, special_rule: defensive_lines) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wallachian_hospodar, special_rule: warlord)         { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: wallachian_hospodar, special_rule: full_plate)      { |psr| psr.position = 2 }

# ── Heroes ────────────────────────────────────────────────────────────────────

ceres = Profile.find_or_create_by!(name: "Ceres") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 1
  p.size = 30; p.ducats = 19; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 5
  p.keywords = ["Hero", "Unique", "Vampire", "Bride"]
  p.abilities = ["Concealment (+2)", "Frenzied", "Infiltration", "Slippery", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: ceres, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ceres, special_rule: romani_fury)          { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ceres, special_rule: procession_of_brides) { |psr| psr.position = 1 }

cibele = Profile.find_or_create_by!(name: "Cibele") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 1
  p.size = 30; p.ducats = 19; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 5
  p.keywords = ["Hero", "Unique", "Vampire", "Bride", "Discipline (Runes of Sovereignty, Blood Rites, Fateweaving)"]
  p.abilities = ["Expert Sorcerer (1)", "Frenzied", "Mage (2)", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: cibele, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cibele, special_rule: african_bewitching)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cibele, special_rule: procession_of_brides) { |psr| psr.position = 1 }

miriam = Profile.find_or_create_by!(name: "Miriam") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 4
  p.size = 30; p.ducats = 19; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 5
  p.keywords = ["Hero", "Unique", "Vampire", "Bride"]
  p.abilities = ["Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: miriam, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: miriam, special_rule: eastern_swiftness)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: miriam, special_rule: procession_of_brides) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: miriam, special_rule: sisters_of_gelo)      { |psr| psr.position = 2 }

monstrous_stryx = Profile.find_or_create_by!(name: "Monstrous Stryx") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 30; p.will_points = 0; p.command_points = 0
  p.size = 75; p.ducats = 40; p.movement = 6; p.dexterity = 3; p.attack = 5; p.protection = 2; p.mind = 2
  p.keywords = ["Hero", "Vampire", "Unique"]
  p.abilities = ["Bulky", "Flight", "Frenzied", "Mindless", "Slippery", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: monstrous_stryx, weapon: monstrous_claws) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: monstrous_stryx, weapon: baleful_screech)  { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: monstrous_stryx, special_rule: aerial_aggression) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: monstrous_stryx, special_rule: serpentine)        { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: monstrous_stryx, special_rule: rip_and_tear)      { |psr| psr.position = 2 }

aquatic_strigoi = Profile.find_or_create_by!(name: "Aquatic Strigoi") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 1; p.mind = 2
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Fast Swimmer (2)", "Frenzied", "Vampiric Attack (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: aquatic_strigoi, weapon: webbed_talons) { |pw| pw.position = 0 }

cetean_upior = Profile.find_or_create_by!(name: "Cetean Upior") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 17; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 21; p.movement = 3; p.dexterity = 3; p.attack = 5; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Expert Grappler (3)", "Fast Swimmer (2)", "Frenzied", "Vampiric Attack (1)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: cetean_upior, weapon: distended_jaws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cetean_upior, special_rule: hydrodynamic) { |psr| psr.position = 0 }

highborn_servant = Profile.find_or_create_by!(name: "Highborn Servant") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Companion (Vampire)", "Parry (1)"]
end
ProfileWeapon.find_or_create_by!(profile: highborn_servant, weapon: pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: highborn_servant, weapon: sword)  { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: highborn_servant, special_rule: bankroll) { |psr| psr.position = 0 }

hulking_moroi = Profile.find_or_create_by!(name: "Hulking Moroi") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 15; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 1; p.mind = 1
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Bulky", "First Strike (2)", "Frenzied", "Mindless", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: hulking_moroi, weapon: clawed_hands) { |pw| pw.position = 0 }

leech = Profile.find_or_create_by!(name: "Leech") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Frenzied", "Primitive", "Vampiric Attack (3)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: leech, weapon: a_thousand_teeth) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: leech, special_rule: brain_leech) { |psr| psr.position = 0 }

moon_eater = Profile.find_or_create_by!(name: "Moon Eater") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 17; p.will_points = 1; p.command_points = 0
  p.size = 50; p.ducats = 23; p.movement = 4; p.dexterity = 4; p.attack = 5; p.protection = 1; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Berserk", "Brawler (2)", "Fear (-3)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: moon_eater, weapon: brutal_claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: moon_eater, special_rule: lunar_might)      { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: moon_eater, special_rule: devourer_of_will) { |psr| psr.position = 1 }

reaper = Profile.find_or_create_by!(name: "Reaper") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 1; p.mind = 1
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Aerial Attack", "Frenzied", "Mindless", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: reaper, weapon: fangs) { |pw| pw.position = 0 }

seer = Profile.find_or_create_by!(name: "Seer") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 2
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Discipline (Fateweaving)"]
  p.abilities = ["Mage (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: seer, weapon: staff) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: seer, special_rule: soothsaying) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: seer, special_rule: premonition)  { |psr| psr.position = 1 }

spatar = Profile.find_or_create_by!(name: "Spatar") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 2
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 2
  p.keywords = ["Hero", "Vampire", "Soldier"]
  p.abilities = ["Bodyguard (Leader)", "Frenzied", "Parry (1)", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: spatar, weapon: flanged_mace) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: spatar, weapon: coustille)    { |pw| pw.position = 1 }

# ── Special Rules (cont.) ─────────────────────────────────────────────────────

judgement = SpecialRule.find_or_create_by!(name: "Judgement") do |r|
  r.description = "PULSE Command Ability. Pick an enemy character within 6\". That character is Judged until the end of the round. Friendly characters may re-roll their entire Attack Roll (all of it - including the Destiny dice) against an enemy Judged character. When a friendly Mage attempts to Dispel a spell cast by a Judged character, count their Mage (X) level as 1 higher."
end
cast_sentence = SpecialRule.find_or_create_by!(name: "Cast Sentence") do |r|
  r.description = "Whenever a character Judged by this character is killed, this character replenishes 3 Life Points or 1 Command Point."
end
devil_incarnate = SpecialRule.find_or_create_by!(name: "Devil Incarnate") do |r|
  r.description = "This character may attempt to Dispel magic spells as if it has Mage (2). In addition, enemy characters may not use Will Points when in base contact with this character."
end
crimson_feast = SpecialRule.find_or_create_by!(name: "Crimson Feast") do |r|
  r.description = "When this character kills an enemy character with a Combat action, make a Basic MIND roll. All other friendly characters within 3\" with the Vampire keyword replenish 1 Life Point for each Ace rolled."
end
minor_arcana = SpecialRule.find_or_create_by!(name: "Minor Arcana") do |r|
  r.description = "When picking spells for this character, you must also choose 1 additional Cantrip for it to know from a different available Discipline."
end
cartomancy = SpecialRule.find_or_create_by!(name: "Cartomancy") do |r|
  r.description = "If this character successfully casts a Cantrip, this character or any friendly character within 6\" replenishes 1 Will Point."
end
impaler = SpecialRule.find_or_create_by!(name: "Impaler") do |r|
  r.description = "Each time an enemy character is killed within 3\" of this character, this character increases its Fear and Vampiric Attack value by 1."
end
the_end_is_near = SpecialRule.find_or_create_by!(name: "The End is Near") do |r|
  r.description = "At the start of each of this character's turns, this character loses 2 Life Points and gains 1 to either MOVEMENT, DEXTERITY, or ATTACK for the rest of the game."
end
sculler = SpecialRule.find_or_create_by!(name: "Sculler") do |r|
  r.description = "For each character with this ability, you may purchase 1 extra Gondola from the Equipment list. This character may be deployed in water or on a Gondola and may also re-roll failed dice rolls when making Row actions."
end
dredge = SpecialRule.find_or_create_by!(name: "Dredge") do |r|
  r.description = "When this character makes a Row action, any friendly characters with the Water Creature special rule in base contact with the Gondola at the start of its movement may be placed in base contact with the Gondola at the end of its movement."
end
shadow_walker = SpecialRule.find_or_create_by!(name: "Shadow Walker") do |r|
  r.description = "PULSE Command Ability. Pick one friendly character with the Vampire keyword within 1\". Remove this character and place them anywhere out of base contact within 8\" of this character. This placement does not cause Attacks of Opportunity."
end
tarot = SpecialRule.find_or_create_by!(name: "Tarot") do |r|
  r.description = "When using more than one model with this ability, each must select magic from a different Discipline until all are represented."
end
dead_weights = SpecialRule.find_or_create_by!(name: "Dead Weights") do |r|
  r.description = "This character is not deployed like normal. Instead, at the end of the first round, deploy it anywhere on the board in water at least 3\" away from any enemy characters in water. From that point on they take turns just like normal."
end
rejuvenated = SpecialRule.find_or_create_by!(name: "Rejuvenated") do |r|
  r.description = "This character starts the game with only 5 Life Points remaining. However, if they start any turn with 6 or more Life Points, they increase their MOVEMENT, DEXTERITY, ATTACK, and MIND by 1 until the start of their next turn."
end
bloodletting = SpecialRule.find_or_create_by!(name: "Bloodletting") do |r|
  r.description = "At the start of a friendly character with the Vampire keyword's turn, if they are within 3\" of this character they may drain blood. The Vampire character gains 1AP to use during their turn, and the Thrall loses 4 Life Points. This may only be done if the Thrall has at least 4 Life Points remaining, and can result in them dying!"
end

# ── Weapons (cont.) ───────────────────────────────────────────────────────────

gavel           = Weapon.find_or_create_by!(name: "Gavel")           { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = 0;  w.abilities = [] }
meathook        = Weapon.find_or_create_by!(name: "Meathook")        { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = -1; w.abilities = [] }
canine_claws    = Weapon.find_or_create_by!(name: "Canine Claws")    { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = -2; w.abilities = [] }
impaling_stake  = Weapon.find_or_create_by!(name: "Impaling Stake")  { |w| w.range = 2; w.evasion = 0;  w.damage = 2; w.penetration = -1; w.abilities = ["Two-handed"] }
calcified_fists = Weapon.find_or_create_by!(name: "Calcified Fists") { |w| w.range = 0; w.evasion = 1;  w.damage = 1; w.penetration = 0;  w.abilities = ["Stun"] }
fresh_claws     = Weapon.find_or_create_by!(name: "Fresh Claws")     { |w| w.range = 0; w.evasion = -1; w.damage = 0; w.penetration = -1; w.abilities = [] }
sica            = Weapon.find_or_create_by!(name: "Sica")            { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = -1; w.abilities = [] }
oar             = Weapon.find_or_create_by!(name: "Oar")             { |w| w.range = 2; w.evasion = 0;  w.damage = 1; w.penetration = 1;  w.abilities = ["Two-handed"] }
spear           = Weapon.find_or_create_by!(name: "Spear")           { |w| w.range = 2; w.evasion = 0;  w.damage = 1; w.penetration = 0;  w.abilities = ["Two-handed", "Knockback"] }
ancient_claws   = Weapon.find_or_create_by!(name: "Ancient Claws")   { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = -2; w.abilities = [] }
knife           = Weapon.find_or_create_by!(name: "Knife")           { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration = 0;  w.abilities = [] }
claws           = Weapon.find_or_create_by!(name: "Claws")           { |w| w.range = 0; w.evasion = 0;  w.damage = 1; w.penetration = -1; w.abilities = ["Aquatic"] }
battle_axe      = Weapon.find_or_create_by!(name: "Battle Axe")      { |w| w.range = 2; w.evasion = 0;  w.damage = 1; w.penetration =  0; w.abilities = ["Two-handed"] }
crossbow        = Weapon.find_or_create_by!(name: "Crossbow")        { |w| w.range = 30; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = ["Reload (1)", "Two-handed"] }
club            = Weapon.find_or_create_by!(name: "Club")            { |w| w.range = 0; w.evasion = 0;  w.damage = 0; w.penetration =  0; w.abilities = ["Stun"] }
sinking_weights = Weapon.find_or_create_by!(name: "Sinking Weights") { |w| w.range = 2; w.evasion = 0;  w.damage = 2; w.penetration =  0; w.abilities = ["Knockback"] }
short_bow       = Weapon.find_or_create_by!(name: "Short Bow")       { |w| w.range = 12; w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = ["Two-handed", "Reload (3)"] }

# ── Heroes (cont.) ────────────────────────────────────────────────────────────

strige = Profile.find_or_create_by!(name: "Strige") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 1; p.mind = 3
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Flight", "Frenzied", "Hunter", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: strige, weapon: fangs) { |pw| pw.position = 0 }

strigoi_jude = Profile.find_or_create_by!(name: "Strigoi Jude") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 1
  p.size = 30; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Vampire", "Soldier", "Discipline (Blood Rites, Runes of Sovereignty)"]
  p.abilities = ["Frenzied", "Mage (2)", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: strigoi_jude, weapon: gavel) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: strigoi_jude, special_rule: judgement)     { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: strigoi_jude, special_rule: cast_sentence) { |psr| psr.position = 1 }

strigoi_priest = Profile.find_or_create_by!(name: "Strigoi Priest") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: strigoi_priest, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: strigoi_priest, special_rule: devil_incarnate) { |psr| psr.position = 0 }

strigoi_sluger = Profile.find_or_create_by!(name: "Strigoi Sluger") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 14; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Vampire", "Soldier"]
  p.abilities = ["Brawler (2)", "Expert Grappler (2)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: strigoi_sluger, weapon: meathook) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: strigoi_sluger, special_rule: crimson_feast) { |psr| psr.position = 0 }

strzyga = Profile.find_or_create_by!(name: "Strzyga") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 15; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 18; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Expert Offence (2)", "Flight", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: strzyga, weapon: monstrous_claws) { |pw| pw.position = 0 }

tarot_reader = Profile.find_or_create_by!(name: "Tarot Reader") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["Hero", "Discipline (Runes of Sovereignty, Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: tarot_reader, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: tarot_reader, special_rule: minor_arcana) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: tarot_reader, special_rule: cartomancy)   { |psr| psr.position = 1 }

varcolac = Profile.find_or_create_by!(name: "Varcolac") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 3; p.life_points = 14; p.will_points = 3; p.command_points = 0
  p.size = 40; p.ducats = 17; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 1; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["First Strike (1)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: varcolac, weapon: canine_claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: varcolac, special_rule: lunar_might) { |psr| psr.position = 0 }

wallachian_impaler = Profile.find_or_create_by!(name: "Wallachian Impaler") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 14; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 1
  p.keywords = ["Hero", "Vampire", "Soldier"]
  p.abilities = ["Expert Offence (2)", "Fear (-1)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: wallachian_impaler, weapon: impaling_stake) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wallachian_impaler, special_rule: impaler) { |psr| psr.position = 0 }

zoryi = Profile.find_or_create_by!(name: "Zoryi") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 19; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 19; p.movement = 4; p.dexterity = 4; p.attack = 5; p.protection = 3; p.mind = 1
  p.keywords = ["Hero", "Vampire"]
  p.abilities = ["Brawler (2)", "Bulky", "Fear (0)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: zoryi, weapon: calcified_fists) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: zoryi, weapon: fresh_claws)     { |pw| pw.position = 1 }

# ── Henchmen ──────────────────────────────────────────────────────────────────

al_naibii = Profile.find_or_create_by!(name: "Al Naibii") do |p|
  p.version = "2.2.1"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Brave", "First Strike (1)", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: al_naibii, weapon: sica) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: al_naibii, special_rule: the_end_is_near) { |psr| psr.position = 0 }

common_strigoi = Profile.find_or_create_by!(name: "Common Strigoi") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Vampire"]
  p.abilities = ["Expert Offence (1)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: common_strigoi, weapon: fangs) { |pw| pw.position = 0 }

ferryman = Profile.find_or_create_by!(name: "Ferryman") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Fear (-1)"]
end
ProfileWeapon.find_or_create_by!(profile: ferryman, weapon: oar) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ferryman, special_rule: sculler) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ferryman, special_rule: dredge)  { |psr| psr.position = 1 }

giurgiu_guard = Profile.find_or_create_by!(name: "Giurgiu Guard") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman", "Vampire", "Soldier"]
  p.abilities = ["Expert Protection (2)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: giurgiu_guard, weapon: spear) { |pw| pw.position = 0 }

harpy = Profile.find_or_create_by!(name: "Harpy") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 7; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 6; p.movement = 5; p.dexterity = 5; p.attack = 2; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Flight", "Frenzied", "Mindless", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: harpy, weapon: fangs) { |pw| pw.position = 0 }

newborn_strigoi = Profile.find_or_create_by!(name: "Newborn Strigoi") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Vampire"]
  p.abilities = ["Frenzied", "Mindless", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: newborn_strigoi, weapon: fangs) { |pw| pw.position = 0 }

nosferatu = Profile.find_or_create_by!(name: "Nosferatu") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 2
  p.size = 30; p.ducats = 13; p.movement = 3; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman", "Vampire"]
  p.abilities = ["Concealment (+1)", "Frenzied", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: nosferatu, weapon: ancient_claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: nosferatu, special_rule: shadow_walker) { |psr| psr.position = 0 }

romani = Profile.find_or_create_by!(name: "Romani") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Discipline (Blood Rites, Runes of Sovereignty, Fateweaving, Wild Magic)"]
  p.abilities = ["Mage (0)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: romani, weapon: knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: romani, special_rule: tarot) { |psr| psr.position = 0 }

rotter = Profile.find_or_create_by!(name: "Rotter") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 12; p.movement = 3; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Berserk", "Fast Swimmer (2)", "Frenzied", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: rotter, weapon: claws) { |pw| pw.position = 0 }

targoveti = Profile.find_or_create_by!(name: "Targoveti") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 1
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Companion (Vampire)"]
end
ProfileWeapon.find_or_create_by!(profile: targoveti, weapon: battle_axe) { |pw| pw.position = 0 }

thrall = Profile.find_or_create_by!(name: "Thrall") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Vampire)"]
end
ProfileWeapon.find_or_create_by!(profile: thrall, weapon: crossbow) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: thrall, weapon: club)     { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: thrall, special_rule: bloodletting) { |psr| psr.position = 0 }

sinker = Profile.find_or_create_by!(name: "Sinker") do |p|
  p.version = "2.4.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 3; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Vampire"]
  p.abilities = ["Frenzied", "Limited Movement", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: sinker, weapon: sinking_weights) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sinker, special_rule: dead_weights) { |psr| psr.position = 0 }

starved_dhampir = Profile.find_or_create_by!(name: "Starved Dhampir") do |p|
  p.version = "2.3.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 7; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Vampire"]
  p.abilities = ["Frenzied", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: starved_dhampir, weapon: fangs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: starved_dhampir, special_rule: rejuvenated) { |psr| psr.position = 0 }

poenari_scout = Profile.find_or_create_by!(name: "Poenari Scout") do |p|
  p.version = "2.2.0"; p.faction = "strigoi"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Vampire", "Soldier"]
  p.abilities = ["Acrobatic (2)", "Frenzied", "Infiltration", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: poenari_scout, weapon: short_bow) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: poenari_scout, weapon: fangs)     { |pw| pw.position = 1 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Pages 30-33, 35-38, 41-42 produced _a/_b variants; _a is used as primary.
{
  "Vlad Dracula"       => ["p02.png", -6, -6, 115, false],
  "Blood Crone"        => ["p03.png", 20, -23, 85, false],
  "Noble Strigoi"      => ["p04.png", 28, -12, 95, false],
  "Stryha Crone"       => ["p05.png", 1, -16, 100, false],
  "Wallachian Hospodar" => ["p06.png", 4, 10, 100, false],
  "Ceres"              => ["p07.png", 10, -25, 85, false],
  "Cibele"             => ["p08.png", 49, -7, 50, false],
  "Miriam"             => ["p09.png", -18, -9, 90, true],
  "Monstrous Stryx"    => "p10.png",
  "Aquatic Strigoi"    => ["p11.png", 26, -9, 85, false],
  "Cetean Upior"       => ["p12.png", 8, -19, 85, false],
  "Highborn Servant"   => ["p13.png", 22, -26, 90, false],
  "Hulking Moroi"      => ["p14.png", 2, -29, 90, true],
  "Leech"              => ["p15.png", 35, -23, 85, false],
  "Moon Eater"         => ["p16.png", 3, 5, 95, false],
  "Reaper"             => ["p17.png", 0, -20, 85, false],
  "Seer"               => ["p18.png", 0, -22, 90, false],
  "Spatar"             => ["p19.png", 18, -27, 75, false],
  "Strige"             => ["p20.png", 2, -18, 90, false],
  "Strigoi Jude"       => ["p21.png", 5, -20, 85, false],
  "Strigoi Priest"     => ["p22.png", -15, -9, 100, false],
  "Targoveti"          => ["p41_a.png", 33, 9, 80, false],
  "Thrall"             => ["p42_a.png", -5, -12, 90, false],
  "Strigoi Sluger"     => ["p23.png", 33, -17, 110, false],
  "Strzyga"            => "p24.png",
  "Tarot Reader"       => ["p25.png", 6, -16, 95, false],
  "Varcolac"           => "p26.png",
  "Wallachian Impaler" => "p27.png",
  "Zoryi"              => ["p28.png", -1, -13, 90, false],
  "Al Naibii"          => ["p29.png", 23, -1, 80, false],
  "Common Strigoi"     => ["p30_a.png", -8, -20, 90, false],
  "Ferryman"           => ["p31_a.png", 57, 32, 70, false],
  "Giurgiu Guard"      => ["p32_a.png", -71, -28, 150, false],
  "Harpy"              => ["p33_a.png", 27, 43, 100, false],
  "Newborn Strigoi"    => ["p34.png", 19, -12, 90, false],
  "Nosferatu"          => ["p35_a.png", -1, -25, 90, false],
  "Romani"             => ["p36_a.png", 4, -12, 90, false],
  "Rotter"             => ["p37_a.png", 29, -21, 90, false],
  "Sinker"             => ["p38_a.png", 5, -30, 100, false],
  "Starved Dhampir"    => ["p39.png", 2, -29, 80, false],
  "Poenari Scout"      => ["p40.png", 4, 25, 85, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "strigoi", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Common Strigoi" => ["p30_b.png", 0, -8, 95, false],
  "Ferryman"       => ["p31_b.png", 26, -6, 75, false],
  "Giurgiu Guard"  => ["p32_b.png", 14, -36, 100, false],
  "Harpy"          => ["p33_b.png", 34, -35, 60, true],
  "Nosferatu"      => ["p35_b.png", 37, -17, 85, false],
  "Romani"         => "p36_b.png",
  "Rotter"         => "p37_b.png",
  "Sinker"         => ["p38_b.png", 39, -27, 85, false],
  "Targoveti"      => ["p41_b.png", 55, 24, 70, false],
  "Thrall"         => "p42_b.png",
}.each do |name, val|
  profile = Profile.find_by(faction: "strigoi", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

# ── Card References ────────────────────────────────────────────────────────────
profile_map = Profile.where(faction: "strigoi").each_with_object({}) { |p, h| h[p.name] = p.id }
now = Time.current
records = card_ref_data.map do |attrs|
  display_name = case attrs[:identifier]
                 when /-a$/ then "#{attrs[:name]} (A)"
                 when /-b$/ then "#{attrs[:name]} (B)"
                 else attrs[:name]
                 end
  { name: display_name, identifier: attrs[:identifier], profile_id: profile_map[attrs[:name]], created_at: now, updated_at: now }
end
CardReference.upsert_all(records, unique_by: :identifier, update_only: %i[name profile_id])
cr_count = CardReference.where(identifier: records.map { |r| r[:identifier] }).count
p_count  = Profile.where(faction: "strigoi").count
puts "Seeded Strigoi: #{cr_count} card references, #{p_count} profiles."
