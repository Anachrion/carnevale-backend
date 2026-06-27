# ── Special Rules ──────────────────────────────────────────────────────────────

you_there_do_something = SpecialRule.find_or_create_by!(name: "You there! Do something!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, other friendly characters that start their turn within 6\" and line of sight of this character gain First Strike (2) until the end of their turn. Characters can only be affected by this Command Ability once each game round."
end
stop_them = SpecialRule.find_or_create_by!(name: "Stop them, damn you! I don't care what it takes!") do |r|
  r.description = "Friendly characters in line of sight of this character gain Bodyguard (Pinnacle of Affluence)."
end
bask_in_my_magnificence = SpecialRule.find_or_create_by!(name: "Bask in my Magnificence!") do |r|
  r.description = "This character replenishes all of its Command Points at the start of each of its character turns and may use each type of Command (PLAN, COUNTER, etc.) twice per game round."
end
take_arms = SpecialRule.find_or_create_by!(name: "Take Arms") do |r|
  r.description = "PULSE Command Ability. Until the end of the round, all friendly characters with the Soldier keyword within 3\" gain +1 ATTACK."
end
aim_fire = SpecialRule.find_or_create_by!(name: "Aim Fire!") do |r|
  r.description = "PULSE Command Ability. Any friendly characters with the Soldier keyword in line of sight gain Expert Marksman (1) until the end of the round."
end
naval_discipline = SpecialRule.find_or_create_by!(name: "Naval Discipline") do |r|
  r.description = "PULSE Command Ability. Other friendly characters on the same Boat as this character replenish 1 Will Point. Other friendly characters with Boat Crew on the same Boat as this character instead replenish 2 Will Points."
end
raise_a_crew = SpecialRule.find_or_create_by!(name: "Raise a Crew") do |r|
  r.description = "All friendly characters may be set up on a Boat."
end
twin_pistols = SpecialRule.find_or_create_by!(name: "Twin Pistols") do |r|
  r.description = "This character's weapons share the Reload ability - you may make 2 Combat actions with the Rifled Duelling Pistol or 1 with Twin Rifled Duelling Pistols in one round."
end
unwieldy = SpecialRule.find_or_create_by!(name: "Unwieldy") do |r|
  r.description = "This character may only make Combat actions with its ranged weapon as the first action of their turn (including using it for Attacks of Opportunity)."
end
monster_behind_mask = SpecialRule.find_or_create_by!(name: "The Monster Behind the Mask") do |r|
  r.description = "PULSE Command Ability. This character gains +1 to its MOVEMENT, DEXTERITY, and ATTACK until the end of the round. However, it reduces its MIND to 1."
end
murderous_patron = SpecialRule.find_or_create_by!(name: "Murderous Patron") do |r|
  r.description = "Any other friendly character that kills an enemy character replenishes 1 Will Point if both are in line of sight to the Venetian Noble."
end
do_try_to_keep_up = SpecialRule.find_or_create_by!(name: "Do Try To Keep Up!") do |r|
  r.description = "Once per round, before this character makes a Run/Climb action, you may choose 1 other friendly character with the Councillor, Soldier, or Animal keyword within 3\". After this character completes that Run/Climb action, the chosen character makes an out of sequence Run/Climb action. This out of sequence action cannot cause Attacks of Opportunity from charging, but may require a character to Disengage as normal."
end
venetian_drive = SpecialRule.find_or_create_by!(name: "Venetian Drive") do |r|
  r.description = "PULSE Command Ability. This character gains First Strike (2) until the end of the round, however it reduces its PROTECTION to 1."
end
gleeful_charge = SpecialRule.find_or_create_by!(name: "Gleeful Charge") do |r|
  r.description = "When this character makes an Attack of Opportunity due to charging, Gilded Sabre's Evasion becomes -4 for that Attack of Opportunity."
end
coordinated_attack = SpecialRule.find_or_create_by!(name: "Coordinated Attack") do |r|
  r.description = "PULSE Command Ability. All friendly characters with the Ottoman keyword within 3\" (including this one) gain First Strike (2) until the end of the round."
end
disciplined_momentum = SpecialRule.find_or_create_by!(name: "Disciplined Momentum") do |r|
  r.description = "When a friendly character with the Ottoman keyword within 6\" and line of sight kills an enemy character, this character replenishes 1 lost Command Point."
end
martial_elite = SpecialRule.find_or_create_by!(name: "Martial Elite") do |r|
  r.description = "Friendly characters with the Ottoman keyword within 6\" may use their Expert Offence ability on the Destiny Dice."
end
wages_are_here = SpecialRule.find_or_create_by!(name: "Wages Are Here") do |r|
  r.description = "PULSE Command Ability. Any friendly characters in line of sight with the Soldier keyword that aren't in base contact with an enemy may immediately make a Run/Climb action for 0AP, but must move into base contact with this character. This move does not cause Attacks of Opportunity. Any characters that move into base contact immediately replenish 1 Will Point."
end
pay_out = SpecialRule.find_or_create_by!(name: "Pay Out") do |r|
  r.description = "Any friendly character within 6\" may use this character's Will Points as if they were their own."
end
second_in_command = SpecialRule.find_or_create_by!(name: "Second in Command") do |r|
  r.description = "If this is the only character with the Leader keyword in the gang, this character loses the Hero keyword and no other Sopracomitos may be chosen. However, if there is another character with the Leader keyword, this character loses the Leader keyword."
end
collector_of_treasures = SpecialRule.find_or_create_by!(name: "Collector of Treasures") do |r|
  r.description = "When building your gang, if it contains this character, you may purchase a second Artifact. This character may also have a purchased Artifact as if it did not have the Unique keyword. If this character is killed while carrying an Artifact, place a marker (use a 30mm base) for that Artifact in base contact with this character, then remove this character from the board. Any character that ends an action in base contact with one of these markers may remove that marker to claim and carry that Artifact."
end
little_gremlin_cornelius = SpecialRule.find_or_create_by!(name: "Little Gremlin Cornelius") do |r|
  r.description = "This character automatically carries this Artifact at the start of the game (not counting towards Artifact limits). A character with this Artifact gains the Cornelius' Bite weapon and Pickpocket special rule."
end
rings_of_puissance = SpecialRule.find_or_create_by!(name: "Rings of Puissance") do |r|
  r.description = "This character automatically carries this Artifact at the start of the game (not counting towards Artifact limits). A character with this Artifact gains Slippery and Universal Shielding (3)."
end
arcane_totem = SpecialRule.find_or_create_by!(name: "Arcane Totem") do |r|
  r.description = "This character knows every spell (including the Cantrip) from the Wild Magic Discipline. Each spell costs 0 Will Points to cast, but may only be attempted once per game. In addition, if this character ever fails to cast a spell, another spell is also removed at random."
end
take_aim = SpecialRule.find_or_create_by!(name: "Take Aim!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, all friendly characters with the Soldier keyword within 6\" gain Expert Marksman (1) and Expert Offence (1)."
end
chain_of_command = SpecialRule.find_or_create_by!(name: "Chain of Command") do |r|
  r.description = "This character may only use the ORDER or COUNTER Commands on characters with the Soldier keyword."
end
strike_true = SpecialRule.find_or_create_by!(name: "Strike True") do |r|
  r.description = "1AP. Pick one friendly character in line of sight within 6\". The next Combat action they make this round while in base contact with the target ignores all Protection Rolls - even Universal Shielding!"
end
business_or_pleasure = SpecialRule.find_or_create_by!(name: "Business or Pleasure?") do |r|
  r.description = "Any friendly character with the Councillor keyword with 0 Command Points remaining replenishes 1 Command Point if they start their turn within 6\" and line of sight of this character."
end
the_other_other_white_meat = SpecialRule.find_or_create_by!(name: "The Other, Other White Meat") do |r|
  r.description = "AURA Command Ability. Until the end of the round, every other friendly character in line of sight gains the Flesheater ability while in line of sight of this character."
end
flesheater = SpecialRule.find_or_create_by!(name: "Flesheater") do |r|
  r.description = "If this character makes a Combat action against a target in base contact that causes it to lose at least 1 Life Point, it replenishes 1 Will Point."
end
we_trained_for_this = SpecialRule.find_or_create_by!(name: "We Trained For This") do |r|
  r.description = "AURA Command Ability. All friendly characters within 6\" increase their Fast Swimmer (X) value by 2 until the end of the round. Any characters without Fast Swimmer are unaffected."
end
black_powder_arrows = SpecialRule.find_or_create_by!(name: "Black Powder Arrows") do |r|
  r.description = "Any friendly Ottoman Archer within 3\" of this character may use its Black Powder Grenade as if it were listed on their own profile when making a Combat action."
end
barbary_discipline = SpecialRule.find_or_create_by!(name: "Barbary Discipline") do |r|
  r.description = "AURA Command Ability. Until the end of the round, all friendly characters within 6\" gain +2 MOVEMENT if their Run/Climb action is used to charge."
end
inspiring = SpecialRule.find_or_create_by!(name: "Inspiring") do |r|
  r.description = "Whenever another friendly character with the Soldier keyword in line of sight within 6\" of this character uses one of its own Will Points (and not those from other characters), it instead counts as 2 Will Points."
end
domination = SpecialRule.find_or_create_by!(name: "Domination") do |r|
  r.description = "PULSE Command Ability. Every friendly character in base contact makes an immediate Move action for 0AP. This action cannot be used to move into base contact with an enemy character."
end
sadism = SpecialRule.find_or_create_by!(name: "Sadism") do |r|
  r.description = "PULSE Command Ability. This character loses 1 Life Point and gains +2 Attack until the end of the round."
end
barbed = SpecialRule.find_or_create_by!(name: "Barbed") do |r|
  r.description = "If a Combat action with the Cat O'Nine Tails results in no Protection roll for the target, add 2 to the Damage."
end
gun_laying = SpecialRule.find_or_create_by!(name: "Gun Laying") do |r|
  r.description = "1AP. Pick a friendly character within 6\" and line of sight. Until the end of that character's next activation, it gains -2 Evasion against targets outside of base contact with it."
end
maps_and_charts = SpecialRule.find_or_create_by!(name: "Maps and Charts") do |r|
  r.description = "Whenever this character uses a Plan command, draw 2 extra Agendas, take a look, and discard 2 of your choice."
end
nautical_bearings = SpecialRule.find_or_create_by!(name: "Nautical Bearings") do |r|
  r.description = "Any friendly character that makes a Combat action within 3\" with a weapon that has a range of 6\" or higher increases their range by 6\"."
end

# ── Weapons ───────────────────────────────────────────────────────────────────

strices_paw                  = Weapon.find_or_create_by!(name: "Strice's Paw")                  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
gilded_table_scraps          = Weapon.find_or_create_by!(name: "Gilded Table Scraps")            { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Harmless", "Stun", "Reload (1)"] }
minty_fresh_breath           = Weapon.find_or_create_by!(name: "Minty Fresh Breath")             { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Poisoned", "Template", "Reload (1)"] }
gilded_sabre                 = Weapon.find_or_create_by!(name: "Gilded Sabre")                   { |w| w.range = 0;  w.evasion = -1; w.damage = 1;  w.penetration = -1; w.abilities = [] }
rifled_duelling_pistol       = Weapon.find_or_create_by!(name: "Rifled Duelling Pistol")         { |w| w.range = 12; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
twin_rifled_duelling_pistols = Weapon.find_or_create_by!(name: "Twin Rifled Duelling Pistols")   { |w| w.range = 12; w.evasion = 0;  w.damage = 3;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (1)"] }
cup_rapier                   = Weapon.find_or_create_by!(name: "Cup Rapier")                     { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
garter_pistol                = Weapon.find_or_create_by!(name: "Garter Pistol")                  { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = ["Black Powder", "Reload (2)"] }
flanged_mace                 = Weapon.find_or_create_by!(name: "Flanged Mace")                   { |w| w.range = 0;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Knockback"] }
naval_cutlass                = Weapon.find_or_create_by!(name: "Naval Cutlass")                  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
cane_sword                   = Weapon.find_or_create_by!(name: "Cane Sword")                     { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
cornelius_bite               = Weapon.find_or_create_by!(name: "Cornelius' Bite")                { |w| w.range = 6;  w.evasion = -1; w.damage = 0;  w.penetration = -1; w.abilities = [] }
shadow_touch                 = Weapon.find_or_create_by!(name: "Shadow Touch")                   { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = ["Stun"] }
blinding_flash               = Weapon.find_or_create_by!(name: "Blinding Flash")                 { |w| w.range = 6;  w.evasion = 1;  w.damage = 0;  w.penetration = -2; w.abilities = ["Knockback", "Reload (2)"] }
sword                        = Weapon.find_or_create_by!(name: "Sword")                          { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
officers_sabre               = Weapon.find_or_create_by!(name: "Officer's Sabre")                { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
stiletto                     = Weapon.find_or_create_by!(name: "Stiletto")                       { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 1;  w.abilities = [] }
balanced_rapier              = Weapon.find_or_create_by!(name: "Balanced Rapier")                { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = -2; w.abilities = [] }
sabre                        = Weapon.find_or_create_by!(name: "Sabre")                          { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = 0;  w.abilities = [] }
carving_knife                = Weapon.find_or_create_by!(name: "Carving Knife")                  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
nock_gun                     = Weapon.find_or_create_by!(name: "Nock Gun")                       { |w| w.range = 12; w.evasion = 0;  w.damage = 3;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (1)"] }
black_powder_grenade         = Weapon.find_or_create_by!(name: "Black Powder Grenade")           { |w| w.range = 6;  w.evasion = 1;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Black Powder", "Blast", "Reload (1)"] }
knife                        = Weapon.find_or_create_by!(name: "Knife")                          { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
grapeshot                    = Weapon.find_or_create_by!(name: "Grapeshot")                      { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = -4; w.abilities = ["Black Powder", "Template", "Reload (1)"] }
cannon_barrel                = Weapon.find_or_create_by!(name: "Cannon Barrel")                  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
twin_swords                  = Weapon.find_or_create_by!(name: "Twin Swords")                    { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
battle_axe                   = Weapon.find_or_create_by!(name: "Battle Axe")                     { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Two-handed"] }
service_pistol               = Weapon.find_or_create_by!(name: "Service Pistol")                 { |w| w.range = 8;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = ["Black Powder", "Reload (2)"] }
infantry_sabre               = Weapon.find_or_create_by!(name: "Infantry Sabre")                 { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
cat_o_nine_tails             = Weapon.find_or_create_by!(name: "Cat O'Nine Tails")               { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = [] }
rapier                       = Weapon.find_or_create_by!(name: "Rapier")                         { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
spiked_warhammer_thrust      = Weapon.find_or_create_by!(name: "Spiked Warhammer (thrust)")      { |w| w.range = 1;  w.evasion = -1; w.damage = 0;  w.penetration = -2; w.abilities = [] }
spiked_warhammer_swing       = Weapon.find_or_create_by!(name: "Spiked Warhammer (swing)")       { |w| w.range = 0;  w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Stun"] }
long_rifle                   = Weapon.find_or_create_by!(name: "Long Rifle")                     { |w| w.range = 30; w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = ["Black Powder", "Knockback", "Reload (1)", "Two-handed"] }
unarmed                      = Weapon.find_or_create_by!(name: "Unarmed")                        { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }

# ── Leaders ───────────────────────────────────────────────────────────────────

pinnacle_of_affluence = Profile.find_or_create_by!(name: "Pinnacle of Affluence") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 30; p.will_points = 5; p.command_points = 3
  p.size = 75; p.ducats = 32; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Leader", "Councillor", "Unique"]
  p.abilities = ["Bulky", "Limited Movement", "Expert Grappler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: pinnacle_of_affluence, weapon: strices_paw)         { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: pinnacle_of_affluence, weapon: gilded_table_scraps) { |pw| pw.position = 1 }
ProfileWeapon.find_or_create_by!(profile: pinnacle_of_affluence, weapon: minty_fresh_breath)  { |pw| pw.position = 2 }
ProfileSpecialRule.find_or_create_by!(profile: pinnacle_of_affluence, special_rule: you_there_do_something) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: pinnacle_of_affluence, special_rule: stop_them)               { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: pinnacle_of_affluence, special_rule: bask_in_my_magnificence) { |psr| psr.position = 2 }

guard_commander = Profile.find_or_create_by!(name: "Guard Commander") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 14; p.will_points = 2; p.command_points = 5
  p.size = 30; p.ducats = 20; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 5
  p.keywords = ["Leader", "Officer"]
  p.abilities = ["Brave", "Parry (2)"]
end
ProfileWeapon.find_or_create_by!(profile: guard_commander, weapon: gilded_sabre) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: guard_commander, special_rule: take_arms) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: guard_commander, special_rule: aim_fire)  { |psr| psr.position = 1 }

noble_admiral = Profile.find_or_create_by!(name: "Noble Admiral") do |p|
  p.version = "2.3.1"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 13; p.will_points = 3; p.command_points = 4
  p.size = 30; p.ducats = 19; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 5
  p.keywords = ["Leader", "Councillor", "Officer"]
  p.abilities = ["Boat Crew", "Expert Marksman (2)", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: noble_admiral, weapon: rifled_duelling_pistol)       { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: noble_admiral, weapon: twin_rifled_duelling_pistols) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: noble_admiral, special_rule: naval_discipline) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: noble_admiral, special_rule: raise_a_crew)     { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: noble_admiral, special_rule: twin_pistols)     { |psr| psr.position = 2 }
ProfileSpecialRule.find_or_create_by!(profile: noble_admiral, special_rule: unwieldy)         { |psr| psr.position = 3 }

venetian_noble = Profile.find_or_create_by!(name: "Venetian Noble") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 13; p.will_points = 4; p.command_points = 3
  p.size = 30; p.ducats = 21; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Leader", "Councillor"]
  p.abilities = ["Engage", "Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: venetian_noble, weapon: rifled_duelling_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: venetian_noble, weapon: cup_rapier)             { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: venetian_noble, special_rule: monster_behind_mask) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: venetian_noble, special_rule: murderous_patron)    { |psr| psr.position = 1 }

mounted_venetian_noble = Profile.find_or_create_by!(name: "Mounted Venetian Noble") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 18; p.will_points = 4; p.command_points = 3
  p.size = 50; p.ducats = 24; p.movement = 6; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Leader", "Councillor"]
  p.abilities = ["Engage", "Expert Offence (2)", "Limited Movement"]
end
ProfileWeapon.find_or_create_by!(profile: mounted_venetian_noble, weapon: garter_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: mounted_venetian_noble, weapon: gilded_sabre)  { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: mounted_venetian_noble, special_rule: do_try_to_keep_up) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: mounted_venetian_noble, special_rule: venetian_drive)    { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: mounted_venetian_noble, special_rule: gleeful_charge)    { |psr| psr.position = 2 }

janissary_chorbaji = Profile.find_or_create_by!(name: "Janissary Chorbaji") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 3; p.life_points = 14; p.will_points = 4; p.command_points = 3
  p.size = 30; p.ducats = 23; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 5
  p.keywords = ["Leader", "Ottoman"]
  p.abilities = ["Brawler (1)", "Expert Offence (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: janissary_chorbaji, weapon: flanged_mace) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: janissary_chorbaji, special_rule: coordinated_attack)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: janissary_chorbaji, special_rule: disciplined_momentum) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: janissary_chorbaji, special_rule: martial_elite)        { |psr| psr.position = 2 }

# ── Heroes ────────────────────────────────────────────────────────────────────

sopracomito = Profile.find_or_create_by!(name: "Sopracomito") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 8; p.command_points = 2
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 5; p.mind = 4
  p.keywords = ["Leader", "Hero", "Councillor", "Officer"]
  p.abilities = ["Boat Crew"]
end
ProfileWeapon.find_or_create_by!(profile: sopracomito, weapon: naval_cutlass) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sopracomito, special_rule: wages_are_here)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sopracomito, special_rule: pay_out)           { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: sopracomito, special_rule: second_in_command) { |psr| psr.position = 2 }

don_gregorio_morisini = Profile.find_or_create_by!(name: "Don Gregorio Morisini") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 4; p.command_points = 1
  p.size = 30; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Councillor", "Unique"]
  p.abilities = ["Pickpocket", "Slippery", "Parry (1)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: don_gregorio_morisini, weapon: cane_sword)     { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: don_gregorio_morisini, weapon: cornelius_bite) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: don_gregorio_morisini, special_rule: collector_of_treasures)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: don_gregorio_morisini, special_rule: little_gremlin_cornelius) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: don_gregorio_morisini, special_rule: rings_of_puissance)       { |psr| psr.position = 2 }

moon = Profile.find_or_create_by!(name: "Moon") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 2; p.mind = 5
  p.keywords = ["Hero", "Unique", "Discipline (Blood Rites, Fateweaving)"]
  p.abilities = ["Companion (Sun)", "Flight", "Mage (2)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: moon, weapon: shadow_touch) { |pw| pw.position = 0 }

sun = Profile.find_or_create_by!(name: "Sun") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 5; p.dexterity = 5; p.attack = 5; p.protection = 2; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Acrobatic (3)", "Companion (Moon)", "Expert Marksman (2)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: sun, weapon: blinding_flash) { |pw| pw.position = 0 }

adventuring_noble = Profile.find_or_create_by!(name: "Adventuring Noble") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 16; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Councillor", "Discipline (Wild Magic)"]
  p.abilities = ["Hunter", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: adventuring_noble, weapon: sword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: adventuring_noble, special_rule: arcane_totem) { |psr| psr.position = 0 }

captain_of_the_guard = Profile.find_or_create_by!(name: "Captain of the Guard") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 3
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Officer", "Soldier"]
  p.abilities = ["Bodyguard (Officer)", "Companion (Officer)"]
end
ProfileWeapon.find_or_create_by!(profile: captain_of_the_guard, weapon: officers_sabre) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: captain_of_the_guard, special_rule: take_aim)         { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: captain_of_the_guard, special_rule: chain_of_command) { |psr| psr.position = 1 }

cat_burglar = Profile.find_or_create_by!(name: "Cat Burglar") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 15; p.movement = 5; p.dexterity = 6; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Hero", "Councillor"]
  p.abilities = ["Aerial Attack", "Concealment (+2)", "Infiltration", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: cat_burglar, weapon: stiletto) { |pw| pw.position = 0 }

fencing_master = Profile.find_or_create_by!(name: "Fencing Master") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = ["Engage", "Expert Offence (2)", "Parry (2)"]
end
ProfileWeapon.find_or_create_by!(profile: fencing_master, weapon: balanced_rapier) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: fencing_master, special_rule: strike_true) { |psr| psr.position = 0 }

foreign_dignitary = Profile.find_or_create_by!(name: "Foreign Dignitary") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 2
  p.keywords = ["Hero"]
  p.abilities = ["Companion (Councillor)", "Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: foreign_dignitary, weapon: sabre) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: foreign_dignitary, special_rule: business_or_pleasure) { |psr| psr.position = 0 }

gourmand_noble = Profile.find_or_create_by!(name: "Gourmand Noble") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 1
  p.size = 40; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 1
  p.keywords = ["Hero", "Councillor"]
  p.abilities = ["Engage", "Fear (0)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: gourmand_noble, weapon: carving_knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: gourmand_noble, special_rule: the_other_other_white_meat) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: gourmand_noble, special_rule: flesheater)                 { |psr| psr.position = 1 }

naval_lieutenant = Profile.find_or_create_by!(name: "Naval Lieutenant") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Officer", "Soldier"]
  p.abilities = ["Boat Crew", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: naval_lieutenant, weapon: nock_gun) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: naval_lieutenant, special_rule: we_trained_for_this) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: naval_lieutenant, special_rule: chain_of_command)    { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: naval_lieutenant, special_rule: unwieldy)            { |psr| psr.position = 2 }

janissary_sapper = Profile.find_or_create_by!(name: "Janissary Sapper") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 4
  p.keywords = ["Hero", "Ottoman"]
  p.abilities = ["Expert Marksman (2)", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: janissary_sapper, weapon: black_powder_grenade) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: janissary_sapper, weapon: knife)                { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: janissary_sapper, special_rule: black_powder_arrows) { |psr| psr.position = 0 }

ottoman_cannoneer = Profile.find_or_create_by!(name: "Ottoman Cannoneer") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 15; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["Hero", "Ottoman"]
  p.abilities = ["Brawler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: ottoman_cannoneer, weapon: grapeshot)     { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: ottoman_cannoneer, weapon: cannon_barrel) { |pw| pw.position = 1 }

ottoman_janissary = Profile.find_or_create_by!(name: "Ottoman Janissary") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 3; p.command_points = 2
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 4
  p.keywords = ["Hero", "Ottoman"]
  p.abilities = ["Bodyguard (Leader)", "Brawler (1)", "Expert Offence (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: ottoman_janissary, weapon: twin_swords) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: ottoman_janissary, weapon: battle_axe)  { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: ottoman_janissary, special_rule: barbary_discipline) { |psr| psr.position = 0 }

seven_years_veteran = Profile.find_or_create_by!(name: "Seven Years Veteran") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 5
  p.keywords = ["Hero", "Soldier"]
  p.abilities = ["Brave", "Expert Offence (1)", "Expert Marksman (1)"]
end
ProfileWeapon.find_or_create_by!(profile: seven_years_veteran, weapon: service_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: seven_years_veteran, weapon: infantry_sabre) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: seven_years_veteran, special_rule: inspiring) { |psr| psr.position = 0 }

submissive_noble = Profile.find_or_create_by!(name: "Submissive Noble") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 14; p.will_points = 1; p.command_points = 2
  p.size = 40; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Councillor"]
  p.abilities = ["Frenzied", "Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: submissive_noble, weapon: cat_o_nine_tails) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: submissive_noble, special_rule: domination) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: submissive_noble, special_rule: sadism)     { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: submissive_noble, special_rule: barbed)     { |psr| psr.position = 2 }

syphilitic_noble = Profile.find_or_create_by!(name: "Syphilitic Noble") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 0; p.command_points = 1
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 1
  p.keywords = ["Hero", "Councillor"]
  p.abilities = ["Berserk", "Engage", "Frenzied", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: syphilitic_noble, weapon: rapier) { |pw| pw.position = 0 }

venetian_heavy_guard = Profile.find_or_create_by!(name: "Venetian Heavy Guard") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 15; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 2
  p.keywords = ["Hero", "Soldier"]
  p.abilities = ["Companion (Officer)", "Expert Protection (3)"]
end
ProfileWeapon.find_or_create_by!(profile: venetian_heavy_guard, weapon: spiked_warhammer_thrust) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: venetian_heavy_guard, weapon: spiked_warhammer_swing)  { |pw| pw.position = 1 }

venetian_spy = Profile.find_or_create_by!(name: "Venetian Spy") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero"]
  p.abilities = ["Concealment (+1)", "Expert Marksman (2)", "Infiltration"]
end
ProfileWeapon.find_or_create_by!(profile: venetian_spy, weapon: long_rifle) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: venetian_spy, special_rule: unwieldy) { |psr| psr.position = 0 }

wayfinder = Profile.find_or_create_by!(name: "Wayfinder") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 3
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = []
end
ProfileWeapon.find_or_create_by!(profile: wayfinder, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wayfinder, special_rule: gun_laying)        { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: wayfinder, special_rule: maps_and_charts)   { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: wayfinder, special_rule: nautical_bearings) { |psr| psr.position = 2 }

# ── Henchmen ──────────────────────────────────────────────────────────────────

inferiority_complex = SpecialRule.find_or_create_by!(name: "Inferiority Complex") do |r|
  r.description = "This character cannot use the ORDER or COUNTER Commands."
end
the_hunger = SpecialRule.find_or_create_by!(name: "The Hunger") do |r|
  r.description = "If this character starts its turn within 4\" of one or more enemy characters, it must attempt to move into base contact with one of them."
end
affirmation = SpecialRule.find_or_create_by!(name: "Affirmation") do |r|
  r.description = "At the start of this character's turn, pick one character with the Councillor keyword in line of sight. Both this character and that character replenish 1 Will Point."
end
lookout = SpecialRule.find_or_create_by!(name: "Lookout") do |r|
  r.description = "Once per round, this character may use a single ORDER or COUNTER Command for 0 Command Points if at least 3\" above the target character. However, those Commands may still only be done once per round as usual."
end
theres_coin_in_it = SpecialRule.find_or_create_by!(name: "There's Coin in it for You") do |r|
  r.description = "PULSE Command Ability. One friendly character with the Henchman keyword in line of sight within 6\" gains First Strike (2) until the end of the round."
end
grappling_hook = SpecialRule.find_or_create_by!(name: "Grappling Hook") do |r|
  r.description = "This character never takes damage from Falling."
end

pistol            = Weapon.find_or_create_by!(name: "Pistol")             { |w| w.range = 8;  w.evasion = 1;  w.damage = 0;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
bardiche          = Weapon.find_or_create_by!(name: "Bardiche")           { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Two-handed"] }
musket            = Weapon.find_or_create_by!(name: "Musket")             { |w| w.range = 24; w.evasion = 1;  w.damage = 1;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (1)", "Two-handed"] }
bayonet           = Weapon.find_or_create_by!(name: "Bayonet")            { |w| w.range = 1;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
boot_knife        = Weapon.find_or_create_by!(name: "Boot Knife")         { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
cast_iron_utensil = Weapon.find_or_create_by!(name: "Cast Iron Utensil")  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
bite              = Weapon.find_or_create_by!(name: "Bite")               { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
fishing_spear     = Weapon.find_or_create_by!(name: "Fishing Spear")      { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic", "Two-handed"] }
coach_gun         = Weapon.find_or_create_by!(name: "Coach Gun")          { |w| w.range = 12; w.evasion = 1;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Black Powder", "Reload (1)", "Two-handed"] }
sharpened_dagger  = Weapon.find_or_create_by!(name: "Sharpened Dagger")   { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
dive_knife        = Weapon.find_or_create_by!(name: "Dive Knife")         { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
short_bow         = Weapon.find_or_create_by!(name: "Short Bow")          { |w| w.range = 12; w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Two-handed"] }
twin_blades       = Weapon.find_or_create_by!(name: "Twin Blades")        { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }

barnabotti = Profile.find_or_create_by!(name: "Barnabotti") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Councillor)", "First Strike (1)"]
end
ProfileWeapon.find_or_create_by!(profile: barnabotti, weapon: pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: barnabotti, weapon: sword)  { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: barnabotti, special_rule: inferiority_complex) { |psr| psr.position = 0 }

butler = Profile.find_or_create_by!(name: "Butler") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Councillor)", "Expert Marksman (2)"]
end
ProfileWeapon.find_or_create_by!(profile: butler, weapon: pistol) { |pw| pw.position = 0 }

cannibal_cultist = Profile.find_or_create_by!(name: "Cannibal Cultist") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Mindless", "Frenzied"]
end
ProfileWeapon.find_or_create_by!(profile: cannibal_cultist, weapon: sharpened_dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cannibal_cultist, special_rule: flesheater)  { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cannibal_cultist, special_rule: the_hunger)  { |psr| psr.position = 1 }

cortigiane = Profile.find_or_create_by!(name: "Cortigiane") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Parry (2)"]
end
ProfileWeapon.find_or_create_by!(profile: cortigiane, weapon: rapier) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cortigiane, special_rule: affirmation) { |psr| psr.position = 0 }

city_guard = Profile.find_or_create_by!(name: "City Guard") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Companion (Officer)"]
end
ProfileWeapon.find_or_create_by!(profile: city_guard, weapon: bardiche)       { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: city_guard, weapon: infantry_sabre) { |pw| pw.position = 1 }

guard_marksman = Profile.find_or_create_by!(name: "Guard Marksman") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 12; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Companion (Officer)"]
end
ProfileWeapon.find_or_create_by!(profile: guard_marksman, weapon: musket)  { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: guard_marksman, weapon: bayonet) { |pw| pw.position = 1 }

guard_sentry = Profile.find_or_create_by!(name: "Guard Sentry") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 10; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Acrobatic (2)"]
end
ProfileWeapon.find_or_create_by!(profile: guard_sentry, weapon: boot_knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: guard_sentry, special_rule: lookout) { |psr| psr.position = 0 }

hired_muscle = Profile.find_or_create_by!(name: "Hired Muscle") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 13; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Expert Grappler (1)", "Expert Offence (1)"]
end
ProfileWeapon.find_or_create_by!(profile: hired_muscle, weapon: sword) { |pw| pw.position = 0 }

household_staff = Profile.find_or_create_by!(name: "Household Staff") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 10; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Bodyguard (Councillor)"]
end
ProfileWeapon.find_or_create_by!(profile: household_staff, weapon: cast_iron_utensil) { |pw| pw.position = 0 }

hunting_hound = Profile.find_or_create_by!(name: "Hunting Hound") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 6; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 6; p.movement = 6; p.dexterity = 5; p.attack = 2; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Companion (Councillor)", "Limited Movement", "Mindless", "Engage"]
end
ProfileWeapon.find_or_create_by!(profile: hunting_hound, weapon: bite) { |pw| pw.position = 0 }

merchant = Profile.find_or_create_by!(name: "Merchant") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 3
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Henchman"]
  p.abilities = []
end
ProfileWeapon.find_or_create_by!(profile: merchant, weapon: pistol) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: merchant, special_rule: theres_coin_in_it) { |psr| psr.position = 0 }

naval_ensign = Profile.find_or_create_by!(name: "Naval Ensign") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Companion (Officer)", "Hunter", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: naval_ensign, weapon: fishing_spear) { |pw| pw.position = 0 }

naval_recruit = Profile.find_or_create_by!(name: "Naval Recruit") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Soldier"]
  p.abilities = ["Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: naval_recruit, weapon: naval_cutlass) { |pw| pw.position = 0 }

noble_seafarer = Profile.find_or_create_by!(name: "Noble Seafarer") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Councillor"]
  p.abilities = ["Boat Crew", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: noble_seafarer, weapon: coach_gun)  { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: noble_seafarer, weapon: dive_knife) { |pw| pw.position = 1 }

ottoman_archer = Profile.find_or_create_by!(name: "Ottoman Archer") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Ottoman"]
  p.abilities = ["Boat Crew", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: ottoman_archer, weapon: short_bow) { |pw| pw.position = 0 }

ottoman_pirate = Profile.find_or_create_by!(name: "Ottoman Pirate") do |p|
  p.version = "2.3.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Ottoman"]
  p.abilities = ["Boat Crew", "Parry (1)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: ottoman_pirate, weapon: twin_blades) { |pw| pw.position = 0 }

ottoman_rigger = Profile.find_or_create_by!(name: "Ottoman Rigger") do |p|
  p.version = "2.2.0"; p.faction = "patricians"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 6; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Ottoman"]
  p.abilities = ["Boat Crew"]
end
ProfileWeapon.find_or_create_by!(profile: ottoman_rigger, weapon: knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ottoman_rigger, special_rule: grappling_hook) { |psr| psr.position = 0 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → p(N-1).png. Page 1 is the faction rules page (no profile).
# p28_a/p29_a: pages 29-30 produced _a/_b variants; _a is used as primary.
# p30 and p38 were not extracted; Cortigiane and Naval Ensign have no illustration.

{
  "Pinnacle of Affluence"  => ["p02.png", 1, 1, 95, false],
  "Guard Commander"        => ["p03.png", -25, -3, 100, false],
  "Noble Admiral"          => ["p04.png", -16, 0, 90, true],
  "Venetian Noble"         => ["p05.png", -6, -30, 90, false],
  "Mounted Venetian Noble" => ["p06.png", -20, -13, 105, false],
  "Janissary Chorbaji"     => ["p07.png", -1, -8, 100, false],
  "Sopracomito"            => ["p08.png", 17, -32, 85, false],
  "Don Gregorio Morisini"  => ["p09.png", 22, -29, 85, false],
  "Moon"                   => ["p10.png", -46, -4, 105, false],
  "Sun"                    => ["p11.png", -9, 4, 115, false],
  "Adventuring Noble"      => ["p12.png", -4, -25, 100, false],
  "Captain of the Guard"   => ["p13.png", 0, -1, 95, true],
  "Cat Burglar"            => ["p14.png", 4, -8, 90, true],
  "Fencing Master"         => ["p15.png", 9, -14, 90, false],
  "Foreign Dignitary"      => ["p16.png", -7, -19, 85, false],
  "Gourmand Noble"         => ["p17.png", 6, -19, 90, false],
  "Naval Lieutenant"       => ["p18.png", -3, -17, 90, false],
  "Janissary Sapper"       => ["p19.png", -1, -15, 90, false],
  "Ottoman Cannoneer"      => ["p20.png", 9, -16, 90, false],
  "Ottoman Janissary"      => ["p21_a.png", 35, -8, 60, false],
  "Seven Years Veteran"    => ["p22.png", 0, -21, 95, false],
  "Submissive Noble"       => ["p23.png", 6, -23, 90, false],
  "Syphilitic Noble"       => ["p24.png", 6, -22, 90, false],
  "Venetian Heavy Guard"   => ["p25.png", 4, -23, 90, false],
  "Venetian Spy"           => ["p26.png", 25, -20, 85, false],
  "Wayfinder"              => ["p27.png", 17, -27, 85, false],
  "Barnabotti"             => ["p28_a.png", -26, -2, 120, false],
  "Butler"                 => ["p29_a.png", 0, -22, 95, true],
  "Cannibal Cultist"       => ["p30.png", 16, -21, 75, false],
  "Cortigiane"             => ["p31_a.png", 15, 6, 80, true],
  "City Guard"             => ["p32_a.png", -12, -8, 100, false],
  "Guard Marksman"         => ["p33.png", 33, -15, 90, false],
  "Guard Sentry"           => ["p34.png", -33, -20, 95, false],
  "Hired Muscle"           => ["p35.png", 4, -36, 85, false],
  "Household Staff"        => ["p36_a.png", 28, -32, 80, false],
  "Hunting Hound"          => ["p37_a.png", 32, -52, 80, false],
  "Merchant"               => ["p38_a.png", 11, -18, 90, false],
  "Naval Ensign"           => ["p39.png", -1, -12, 100, false],
  "Naval Recruit"          => ["p40_a.png", -4, 9, 100, false],
  "Noble Seafarer"         => ["p41_a.png", -18, -32, 120, false],
  "Ottoman Archer"         => ["p42.png", 18, -32, 75, false],
  "Ottoman Pirate"         => ["p43.png", 8, -25, 85, false],
  "Ottoman Rigger"         => ["p44.png", 8, -20, 80, false],
}.each do |name, val|
  next unless val
  profile = Profile.find_by(faction: "patricians", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Ottoman Janissary" => ["p21_b.png", 36, -10, 85, false],
  "Barnabotti"        => ["p28_b.png", 12, 9, 85, false],
  "Butler"            => ["p29_b.png", 23, -24, 70, true],
  "Cortigiane"        => ["p31_b.png", -64, -18, 90, false],
  "City Guard"        => ["p32_b.png", -39, 6, 100, false],
  "Household Staff"   => ["p36_b.png", 22, -29, 80, true],
  "Hunting Hound"     => ["p37_b.png", 3, -61, 75, false],
  "Merchant"          => ["p38_b.png", 26, -28, 80, false],
  "Naval Recruit"     => "p40_b.png",
  "Noble Seafarer"    => ["p41_b.png", 14, -8, 100, false],
}.each do |name, val|
  next unless val
  profile = Profile.find_by(faction: "patricians", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end
