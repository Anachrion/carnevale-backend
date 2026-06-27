# ── The Doctors ────────────────────────────────────────────────────────────────

# Special Rules
mind_gazing = SpecialRule.find_or_create_by!(name: "Mind Gazing") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 6\" gain Fear (-2), or increase their Fear number to (-2)."
end
aetheric_control = SpecialRule.find_or_create_by!(name: "Aetheric Control") do |r|
  r.description = "This character replenishes all of its Command Points at the start of each of its turns."
end
unliving_curse = SpecialRule.find_or_create_by!(name: "Unliving Curse") do |r|
  r.description = "PULSE Command Ability. One friendly character within 1\" gains Vampiric Attack (2) until the end of the game."
end
elixir_of_death = SpecialRule.find_or_create_by!(name: "Elixir of Death") do |r|
  r.description = "Every friendly character who starts the game with Will Points loses all of their Will Points and gains Frenzied. This change remains in play even if this character is killed. Note that characters with the Nexus ability may still use their Life Points as Will Points, even for other characters! In addition, change the Nexus Link Reconfiguration Command Ability: every time it mentions Will Points, change it to Life Points."
end
electrical_stimulation = SpecialRule.find_or_create_by!(name: "Electrical Stimulation") do |r|
  r.description = "PULSE Command Ability. All friendly characters within 3\" gain +1 ATTACK until the end of the round."
end
auxiliary_systems = SpecialRule.find_or_create_by!(name: "Auxiliary Systems") do |r|
  r.description = "At the start of this character's turn, it gains +2 to either its MOVEMENT, DEXTERITY, or PROTECTION until the end of the round."
end
full_plate = SpecialRule.find_or_create_by!(name: "Full Plate") do |r|
  r.description = "If this character ever enters water, it receives a Stunned counter which is only removed if it ends its turn out of water."
end
protective_field = SpecialRule.find_or_create_by!(name: "Protective Field") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain Universal Shielding (4)."
end
beast_master = SpecialRule.find_or_create_by!(name: "Beast Master") do |r|
  r.description = "All friendly characters with the Animal keyword gain Companion (Doctor) while in line of sight of this character."
end
voltaic_shield = SpecialRule.find_or_create_by!(name: "Voltaic Shield") do |r|
  r.description = "If an enemy character makes a Combat action against this character in base contact and they don't lose any Life Points from the attack, the enemy character loses 3 Life Points."
end
biological_studies = SpecialRule.find_or_create_by!(name: "Biological Studies") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain Penetration -2 on their weapons."
end
purifying_ungents = SpecialRule.find_or_create_by!(name: "Purifying Ungents") do |r|
  r.description = "While within 6\" of this character, friendly characters are immune to the Stun Ability. At the end of each friendly character's turn, remove any Stun counters from friendly characters within 6\" of this character."
end
plague_infused_anatomy = SpecialRule.find_or_create_by!(name: "Plague-infused Anatomy") do |r|
  r.description = "If an enemy character kills a friendly character in base contact while either are within 6\" of this character, the enemy receives a Stunned counter."
end
nexus = SpecialRule.find_or_create_by!(name: "Nexus") do |r|
  r.description = "Any character with the Doctor keyword within 6\" and line of sight may use this character's Will Points as if they were their own."
end
madness_infused_muscle = SpecialRule.find_or_create_by!(name: "Madness Infused Muscle") do |r|
  r.description = "If this character rolls no Aces for its Primitive rolls, instead of receiving a Stunned counter, it makes a Run/Climb action towards the nearest other character (friendly or enemy) and then makes a Combat action against it. This character then replenishes 1 Will Point and activates as normal (with full AP)."
end
locomotive_nexus_link = SpecialRule.find_or_create_by!(name: "Locomotive Nexus Link") do |r|
  r.description = "Whenever this character makes a Combat action, total up the amount of Damage caused (before Protection rolls). That many characters within 6\" with the Nexus ability replenish 1 Will Point."
end
pain_suppression = SpecialRule.find_or_create_by!(name: "Pain Suppression") do |r|
  r.description = "Whenever this character takes Damage from a Combat action, reduce the amount of Damage caused by 1 (to a minimum of 1)."
end
convulsing = SpecialRule.find_or_create_by!(name: "Convulsing") do |r|
  r.description = "This character is able to move through spaces smaller than its base to a minimum of 2\". It must be able to fit where it ends its turn."
end
flesh_golem = SpecialRule.find_or_create_by!(name: "Flesh Golem") do |r|
  r.description = "Every time this character kills a character, it replenishes a number of Life Points equal to that character's starting Life Points."
end
sanguine_sorcery = SpecialRule.find_or_create_by!(name: "Sanguine Sorcery") do |r|
  r.description = "This character's Vampiric Attack also activates when making a Cast Spell action."
end
probable_statistics = SpecialRule.find_or_create_by!(name: "Probable Statistics") do |r|
  r.description = "1WP. Change the result of the Destiny Dice in any roll (for you or your opponent) for a character within 6\" and line of sight to either a 1 or a 10."
end
long_dive = SpecialRule.find_or_create_by!(name: "Long Dive") do |r|
  r.description = "PULSE Command Ability. All friendly characters with an Underwater Counter gain an additional Underwater Counter."
end
deep_dive = SpecialRule.find_or_create_by!(name: "Deep Dive") do |r|
  r.description = "Whenever this character makes a Dive action, you may spend 1 Will Point. If you do, you automatically score a Critical without rolling any dice."
end
elixir_doctors = SpecialRule.find_or_create_by!(name: "Elixir") do |r|
  r.description = "PULSE Command Ability. One friendly character within 3\" gains either Acrobatic (3), Engage, or Slippery until the end of the game."
end
overcharged_discipline = SpecialRule.find_or_create_by!(name: "Overcharged Discipline") do |r|
  r.description = "PULSE Command Ability. One friendly character with the Animal keyword within 6\" gains Berserk until the end of the game."
end
void_walker = SpecialRule.find_or_create_by!(name: "Void Walker") do |r|
  r.description = "PULSE Command Ability. One friendly character within 3\" gains Ethereal until the end of the game."
end
aetheric_gaze = SpecialRule.find_or_create_by!(name: "Aetheric Gaze") do |r|
  r.description = "This character may select its Magic Spells from up to 2 different Disciplines. It also gains Cantrips from both Disciplines chosen."
end
stride_through_the_void = SpecialRule.find_or_create_by!(name: "Stride Through The Void") do |r|
  r.description = "1AP. This character gains Ethereal until the end of its turn."
end
drag_through_the_void = SpecialRule.find_or_create_by!(name: "Drag Through The Void") do |r|
  r.description = "Targets of this character's Grapple actions may be moved as if they had the Ethereal special rule."
end
unstable = SpecialRule.find_or_create_by!(name: "Unstable") do |r|
  r.description = "Any failed Combat actions with Alchemical Bombs and Poison Bombs always count as fumbles."
end
power_over_death = SpecialRule.find_or_create_by!(name: "Power Over Death") do |r|
  r.description = "PULSE Command Ability. Used out of sequence when any other friendly character within 3\" is killed. Make a Basic MIND Roll: Success — for each Ace rolled, the target replenishes 2 Life Points. Fail — no effect. Critical — for each Ace rolled, the target replenishes 4 Life Points. Fumble — this character loses half its remaining Life Points (rounding up)."
end
soul_ammunition = SpecialRule.find_or_create_by!(name: "Soul Ammunition") do |r|
  r.description = "When making a Combat action with the Spirit Cannon, this character may use 2 Will Points to have it gain one of the following for that action: Increase Range from 12\" to 18\"; Gain the Blast ability; Gain the Knockback ability."
end
detonation = SpecialRule.find_or_create_by!(name: "Detonation") do |r|
  r.description = "When placing the Blast template for Soul Bombard, it must be centred over this character (and is also hit)."
end
explosive_mind = SpecialRule.find_or_create_by!(name: "Explosive Mind") do |r|
  r.description = "Whenever this character loses Will Points (through using them itself or being used as part of the Nexus special rule), after the action is resolved, it must immediately make an out of sequence Combat action using Soul Bombard. This is done only once per action. Combat actions caused by Explosive Mind cannot cause additional Combat actions."
end
apprenticeship = SpecialRule.find_or_create_by!(name: "Apprenticeship") do |r|
  r.description = "When choosing this character, pick one character in your gang with both the Doctor and Hero keywords to be this character's mentor. Choose one Character Ability, unique skill, or weapon profile that mentor has for this character to gain. A character can only be a mentor to one Apprentice Doctor. If choosing the Mage ability, the disciplines available are the same as the mentor. If choosing a weapon with a relevant unique rule, that rule is taken as well (such as Unstable on Alchemical Bombs)."
end
poison_burst = SpecialRule.find_or_create_by!(name: "Poison Burst") do |r|
  r.description = "When this character is killed, before removing it from the game, each character in base contact (friendly and enemy) loses Life Points as if they were damaged by an attack with the Poisoned rule."
end
volatile_arc_power = SpecialRule.find_or_create_by!(name: "Volatile Arc Power") do |r|
  r.description = "After resolving a successful Combat action with an Electron Cannon, pick 1 other character within 3\" of the target (friend or foe – including this character), they lose an equal amount of Life Points as the original target. If there are no other characters in range, this rule has no effect."
end
unstable_wretch = SpecialRule.find_or_create_by!(name: "Unstable Wretch") do |r|
  r.description = "From the start of the second round onwards, at the end of this character's turn all characters (friendly and enemy, including this character) within 3\" lose 1 Life Point."
end
bereft_of_will = SpecialRule.find_or_create_by!(name: "Bereft of Will") do |r|
  r.description = "Other characters within 3\" cannot use Will Points (including Frenzied and Will Points of other characters). When this character dies, all other characters within 3\" lose 1 Will Point."
end
blood_nexus = SpecialRule.find_or_create_by!(name: "Blood Nexus") do |r|
  r.description = "Every time this character loses Life Points (including from the Frenzied rule), you may replenish that many Will Points from all characters within 6\" with the Nexus ability."
end
death_throes_overload = SpecialRule.find_or_create_by!(name: "Death Throes Overload") do |r|
  r.description = "When this character dies, every character with the Doctor keyword within 6\" replenishes 2 Will Points."
end
shepherd = SpecialRule.find_or_create_by!(name: "Shepherd") do |r|
  r.description = "This character gains +2 ATTACK when making Grapple actions against characters with a larger base size."
end
corpse = SpecialRule.find_or_create_by!(name: "Corpse") do |r|
  r.description = "If this character takes 4 or more Damage in one action (before making a Protection roll), add 2 extra Damage to the attack."
end
spined_hide = SpecialRule.find_or_create_by!(name: "Spined Hide") do |r|
  r.description = "At the end of this character's turn, all enemy characters in base contact lose 1 Life Point."
end
healer = SpecialRule.find_or_create_by!(name: "Healer") do |r|
  r.description = "1AP. Pick a character within 3\" and make a basic MIND roll. That character replenishes 2 Life Points for each Ace rolled."
end
regenerating = SpecialRule.find_or_create_by!(name: "Regenerating") do |r|
  r.description = "This character's Vampiric Attack special rule can cause it to gain Life Points above its starting value. If they start their turn with 10 or more Life Points, they increase their ATTACK by 2 until the start of their next turn."
end

# Weapons
surgical_tools     = Weapon.find_or_create_by!(name: "Surgical Tools")          { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = [] }
electrified_mace   = Weapon.find_or_create_by!(name: "Electrified Mace")        { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = -2; w.abilities = ["Stun"] }
arming_blade       = Weapon.find_or_create_by!(name: "Arming Blade")            { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0;  w.abilities = [] }
soul_burner        = Weapon.find_or_create_by!(name: "Soul Burner")             { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -3; w.abilities = ["Template", "Reload (1)"] }
scalpel            = Weapon.find_or_create_by!(name: "Scalpel")                 { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = [] }
bladed_limbs       = Weapon.find_or_create_by!(name: "Bladed Limbs")            { |w| w.range = 0; w.evasion = -1; w.damage = 0; w.penetration = -1; w.abilities = [] }
brutal_fists       = Weapon.find_or_create_by!(name: "Brutal Fists")            { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 0;  w.abilities = ["Stun"] }
endless_grasping   = Weapon.find_or_create_by!(name: "Endless Grasping Hands")  { |w| w.range = 0; w.evasion = -1; w.damage = 0; w.penetration = 1;  w.abilities = [] }
webbed_appendages  = Weapon.find_or_create_by!(name: "Webbed Appendages")       { |w| w.range = 0; w.evasion = 1;  w.damage = 1; w.penetration = 0;  w.abilities = ["Aquatic"] }
knife              = Weapon.find_or_create_by!(name: "Knife")                   { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 0;  w.abilities = [] }
predictive_tools   = Weapon.find_or_create_by!(name: "Predictive Tools")        { |w| w.range = 4; w.evasion = 0; w.damage = 0; w.penetration = 0;  w.abilities = ["Reload (2)"] }
diving_trident     = Weapon.find_or_create_by!(name: "Diving Trident")          { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0;  w.abilities = ["Aquatic", "Two-handed"] }
underwater_lime    = Weapon.find_or_create_by!(name: "Underwater Limelight")    { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 0;  w.abilities = ["Harmless", "Stun", "Template"] }
poisoned_blade     = Weapon.find_or_create_by!(name: "Poisoned Blade")          { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0;  w.abilities = ["Poisoned"] }
shock_staff        = Weapon.find_or_create_by!(name: "Shock Staff")             { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0;  w.abilities = ["Knockback", "Stun", "Two-handed"] }
electro_gauntlet   = Weapon.find_or_create_by!(name: "Electro Gauntlet")        { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -2; w.abilities = ["Stun"] }
alchemical_bomb    = Weapon.find_or_create_by!(name: "Alchemical Bomb")         { |w| w.range = 6; w.evasion = 1;  w.damage = 2; w.penetration = 0;  w.abilities = ["Black Powder", "Blast", "Reload (1)"] }
poison_bomb        = Weapon.find_or_create_by!(name: "Poison Bomb")             { |w| w.range = 6; w.evasion = 0; w.damage = 0; w.penetration = 0;  w.abilities = ["Reload (1)", "Poisoned"] }
poisoned_needle    = Weapon.find_or_create_by!(name: "Poisoned Needle")         { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = ["Poisoned"] }
tranq_harpoon      = Weapon.find_or_create_by!(name: "Tranquilliser Harpoon Gun") { |w| w.range = 6;  w.evasion = 1;  w.damage = 1; w.penetration = 0;  w.abilities = ["Reload (1)", "Aquatic", "Two-handed"] }
spirit_cannon      = Weapon.find_or_create_by!(name: "Spirit Cannon")             { |w| w.range = 12; w.evasion = 1;  w.damage = 2; w.penetration = -1; w.abilities = ["Reload (1)", "Two-handed"] }
grasping_tentacles = Weapon.find_or_create_by!(name: "Grasping Tentacles")        { |w| w.range = 2;  w.evasion = -1; w.damage = 0; w.penetration = 0;  w.abilities = [] }
soul_bombard       = Weapon.find_or_create_by!(name: "Soul Bombard")              { |w| w.range = 0;  w.evasion = 0;  w.damage = 2; w.penetration = -3; w.abilities = ["Black Powder", "Blast"] }
mace               = Weapon.find_or_create_by!(name: "Mace")                      { |w| w.range = 0;  w.evasion = 1;  w.damage = 1; w.penetration = 0;  w.abilities = ["Knockback"] }
venomous_spray     = Weapon.find_or_create_by!(name: "Venomous Spray")            { |w| w.range = 0;  w.evasion = 1;  w.damage = 0; w.penetration = -2; w.abilities = ["Poisoned", "Template"] }
implanted_tools    = Weapon.find_or_create_by!(name: "Implanted Tools")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = 0;  w.abilities = [] }
enhanced_jaws      = Weapon.find_or_create_by!(name: "Enhanced Jaws")             { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = -3; w.abilities = ["Aquatic"] }
fangs              = Weapon.find_or_create_by!(name: "Fangs")                     { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = 0;  w.abilities = [] }
trident            = Weapon.find_or_create_by!(name: "Trident")                   { |w| w.range = 2;  w.evasion = 0;  w.damage = 0; w.penetration = -1; w.abilities = ["Aquatic", "Two-handed"] }
electron_cannon    = Weapon.find_or_create_by!(name: "Electron Cannon")           { |w| w.range = 12; w.evasion = 0;  w.damage = 1; w.penetration = -1; w.abilities = ["Black Powder", "Two-handed", "Reload (1)"] }
titanic_fists      = Weapon.find_or_create_by!(name: "Titanic Fists")             { |w| w.range = 0;  w.evasion = 0;  w.damage = 1; w.penetration = 0;  w.abilities = [] }
hoof_stomp         = Weapon.find_or_create_by!(name: "Hoof Stomp")                { |w| w.range = 0;  w.evasion = -1; w.damage = 1; w.penetration = 0;  w.abilities = ["Stun"] }
beak_and_claws     = Weapon.find_or_create_by!(name: "Beak & Claws")              { |w| w.range = 0;  w.evasion = -1; w.damage = 0; w.penetration = -1; w.abilities = [] }
meat_hook          = Weapon.find_or_create_by!(name: "Meat Hook")                 { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = -1; w.abilities = [] }
shock_prod         = Weapon.find_or_create_by!(name: "Shock Prod")                { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = 0;  w.abilities = ["Stun"] }
unarmed            = Weapon.find_or_create_by!(name: "Unarmed")                   { |w| w.range = 0;  w.evasion = 0;  w.damage = 0; w.penetration = 1;  w.abilities = [] }
ripping_teeth  = Weapon.find_or_create_by!(name: "Ripping Teeth")  { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = [] }
quilled_spines = Weapon.find_or_create_by!(name: "Quilled Spines") { |w| w.range = 8; w.evasion = 1; w.damage = 0; w.penetration = -1; w.abilities = [] }
hidden_claws   = Weapon.find_or_create_by!(name: "Hidden Claws")   { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = ["Aquatic"] }
rusty_blade    = Weapon.find_or_create_by!(name: "Rusty Blade")    { |w| w.range = 0; w.evasion = 0; w.damage = 2; w.penetration =  0; w.abilities = [] }
rusty_knife    = Weapon.find_or_create_by!(name: "Rusty Knife")    { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = [] }
horns          = Weapon.find_or_create_by!(name: "Horns")          { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration =  0; w.abilities = ["Knockback"] }
tender_claws   = Weapon.find_or_create_by!(name: "Tender Claws")   { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = [] }

# Profiles — Leaders
doctor_of_the_mind = Profile.find_or_create_by!(name: "Doctor of the Mind") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 12; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 22; p.movement = 3; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 6
  p.keywords = ["Leader", "Doctor", "Discipline (Blood Rites, Runes of Sovereignty)"]
  p.abilities = ["Fear (-2)", "Mage (3)", "Parry (3)"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_the_mind, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_mind, special_rule: mind_gazing) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_mind, special_rule: aetheric_control) { |psr| psr.position = 1 }

master_of_necromantic = Profile.find_or_create_by!(name: "Master of Necromantic Studies") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 11; p.will_points = 0; p.command_points = 4
  p.size = 30; p.ducats = 23; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 5
  p.keywords = ["Leader", "Doctor", "Discipline (Blood Rites, Divinity)"]
  p.abilities = ["Expert Sorcerer (1)", "Frenzied", "Mage (2)", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: master_of_necromantic, weapon: surgical_tools) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_necromantic, special_rule: unliving_curse) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_necromantic, special_rule: elixir_of_death) { |psr| psr.position = 1 }

master_of_arcane_security = Profile.find_or_create_by!(name: "Master of Arcane Security") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 22; p.will_points = 4; p.command_points = 3
  p.size = 50; p.ducats = 27; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 5; p.mind = 4
  p.keywords = ["Leader", "Doctor"]
  p.abilities = ["Bulky", "Expert Offense (2)", "Expert Marksman (2)"]
end
ProfileWeapon.find_or_create_by!(profile: master_of_arcane_security, weapon: arming_blade) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: master_of_arcane_security, weapon: soul_burner) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_arcane_security, special_rule: electrical_stimulation) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_arcane_security, special_rule: auxiliary_systems) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_arcane_security, special_rule: full_plate) { |psr| psr.position = 2 }

master_of_zoology = Profile.find_or_create_by!(name: "Master of Zoology") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 14; p.will_points = 4; p.command_points = 3
  p.size = 30; p.ducats = 20; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 4
  p.keywords = ["Leader", "Doctor"]
  p.abilities = ["Expert Protection (2)", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: master_of_zoology, weapon: electrified_mace) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_zoology, special_rule: protective_field) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_zoology, special_rule: beast_master) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: master_of_zoology, special_rule: voltaic_shield) { |psr| psr.position = 2 }

plague_doctor_p = Profile.find_or_create_by!(name: "Plague Doctor") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 13; p.will_points = 2; p.command_points = 4
  p.size = 30; p.ducats = 21; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Leader", "Doctor", "Discipline (Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: plague_doctor_p, weapon: scalpel) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: plague_doctor_p, special_rule: biological_studies) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: plague_doctor_p, special_rule: purifying_ungents) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: plague_doctor_p, special_rule: plague_infused_anatomy) { |psr| psr.position = 2 }

# Profiles — Heroes (Unique)
patient_42 = Profile.find_or_create_by!(name: "Patient 42") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 14; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Berserk", "Engage", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: patient_42, weapon: bladed_limbs) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: patient_42, special_rule: nexus) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: patient_42, special_rule: madness_infused_muscle) { |psr| psr.position = 1 }

the_being = Profile.find_or_create_by!(name: "The Being") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 15; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 5; p.protection = 3; p.mind = 1
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Berserk", "Companion (Doctor)", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: the_being, weapon: brutal_fists) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: the_being, special_rule: locomotive_nexus_link) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: the_being, special_rule: pain_suppression) { |psr| psr.position = 1 }

the_unholy_union = Profile.find_or_create_by!(name: "The Unholy Union") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 3; p.life_points = 40; p.will_points = 0; p.command_points = 0
  p.size = 75; p.ducats = 45; p.movement = 4; p.dexterity = 4; p.attack = 6; p.protection = 1; p.mind = 2
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Bulky", "Expert Grappler (3)", "Fear (-3)", "Limited Movement", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: the_unholy_union, weapon: endless_grasping) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: the_unholy_union, special_rule: convulsing) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: the_unholy_union, special_rule: flesh_golem) { |psr| psr.position = 1 }

# Profiles — Heroes
brined_horror = Profile.find_or_create_by!(name: "Brined Horror") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 25; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 19; p.movement = 3; p.dexterity = 3; p.attack = 6; p.protection = 3; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Bulky", "Fast Swimmer (3)", "Fear (-1)", "Mindless", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: brined_horror, weapon: webbed_appendages) { |pw| pw.position = 0 }

doctor_of_blood = Profile.find_or_create_by!(name: "Doctor of Blood") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 4
  p.keywords = ["Hero", "Doctor", "Discipline (Blood Rites)"]
  p.abilities = ["Frenzied", "Mage (2)", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_blood, weapon: knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_blood, special_rule: sanguine_sorcery) { |psr| psr.position = 0 }

doctor_of_divine_prob = Profile.find_or_create_by!(name: "Doctor of Divine Probabilities") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 5; p.attack = 2; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Human"]
  p.abilities = ["Concealment (+2)", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_divine_prob, weapon: predictive_tools) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_divine_prob, special_rule: probable_statistics) { |psr| psr.position = 0 }

doctor_of_tides = Profile.find_or_create_by!(name: "Doctor of Tides") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 2
  p.size = 40; p.ducats = 18; p.movement = 3; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 4
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Water Creature", "Universal Shielding (2)", "Limited Movement"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_tides, weapon: diving_trident) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: doctor_of_tides, weapon: underwater_lime) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_tides, special_rule: long_dive) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_tides, special_rule: deep_dive) { |psr| psr.position = 1 }

doctor_of_poisons = Profile.find_or_create_by!(name: "Doctor of Poisons") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Expert Offence (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_poisons, weapon: poisoned_blade) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_poisons, special_rule: elixir_doctors) { |psr| psr.position = 0 }

doctor_of_the_beasts = Profile.find_or_create_by!(name: "Doctor of the Beasts") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 4
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_the_beasts, weapon: shock_staff) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_beasts, special_rule: overcharged_discipline) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_beasts, special_rule: beast_master) { |psr| psr.position = 1 }

doctor_of_the_firmament = Profile.find_or_create_by!(name: "Doctor of the Firmament") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 4; p.mind = 5
  p.keywords = ["Hero", "Doctor", "Discipline (Blood Rites, Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (2)", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_the_firmament, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_firmament, special_rule: void_walker) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: doctor_of_the_firmament, special_rule: aetheric_gaze) { |psr| psr.position = 1 }

ethereal_assassin = Profile.find_or_create_by!(name: "Ethereal Assassin") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Concealment (2)", "First Strike (2)"]
end
ProfileWeapon.find_or_create_by!(profile: ethereal_assassin, weapon: poisoned_needle) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ethereal_assassin, special_rule: stride_through_the_void) { |psr| psr.position = 0 }

ethereal_snatcher = Profile.find_or_create_by!(name: "Ethereal Snatcher") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 14; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Engage", "Expert Grappler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: ethereal_snatcher, weapon: electro_gauntlet) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ethereal_snatcher, special_rule: stride_through_the_void) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ethereal_snatcher, special_rule: drag_through_the_void) { |psr| psr.position = 1 }

alchemist_doctor = Profile.find_or_create_by!(name: "Alchemist Doctor") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Brave"]
end
ProfileWeapon.find_or_create_by!(profile: alchemist_doctor, weapon: alchemical_bomb) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: alchemist_doctor, weapon: poison_bomb) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: alchemist_doctor, special_rule: unstable) { |psr| psr.position = 0 }

morgue_doctor = Profile.find_or_create_by!(name: "Morgue Doctor") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Doctor", "Discipline (Divinity, Fateweaving)"]
  p.abilities = ["Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: morgue_doctor, weapon: surgical_tools) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: morgue_doctor, special_rule: power_over_death) { |psr| psr.position = 0 }

marine_biologist = Profile.find_or_create_by!(name: "Marine Biologist") do |p|
  p.version = "2.2.1"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Water Creature", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: marine_biologist, weapon: tranq_harpoon) { |pw| pw.position = 0 }

ordnance_doctor = Profile.find_or_create_by!(name: "Ordnance Doctor") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Doctor"]
  p.abilities = ["Expert Marksman (1)"]
end
ProfileWeapon.find_or_create_by!(profile: ordnance_doctor, weapon: spirit_cannon) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ordnance_doctor, special_rule: soul_ammunition) { |psr| psr.position = 0 }

unleashed_madman = Profile.find_or_create_by!(name: "Unleashed Madman") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Brawler (1)", "Expert Grappler (3)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: unleashed_madman, weapon: grasping_tentacles) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: unleashed_madman, special_rule: nexus) { |psr| psr.position = 0 }

voltage_bombardiers = Profile.find_or_create_by!(name: "Voltage Bombardiers") do |p|
  p.version = "2.3.1"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 10; p.will_points = 4; p.command_points = 0
  p.size = 40; p.ducats = 12; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Brawler (2)", "Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: voltage_bombardiers, weapon: soul_bombard) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: voltage_bombardiers, special_rule: nexus) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: voltage_bombardiers, special_rule: detonation) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: voltage_bombardiers, special_rule: explosive_mind) { |psr| psr.position = 2 }

warden = Profile.find_or_create_by!(name: "Warden") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 13; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 2
  p.keywords = ["Hero"]
  p.abilities = ["Bodyguard (Doctor)", "Expert Protection (2)"]
end
ProfileWeapon.find_or_create_by!(profile: warden, weapon: mace) { |pw| pw.position = 0 }

# Profiles — Henchmen
apprentice_doctor = Profile.find_or_create_by!(name: "Apprentice Doctor") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman", "Doctor"]
  p.abilities = ["Companion (Doctor)"]
end
ProfileWeapon.find_or_create_by!(profile: apprentice_doctor, weapon: scalpel) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: apprentice_doctor, special_rule: apprenticeship) { |psr| psr.position = 0 }

basilisk = Profile.find_or_create_by!(name: "Basilisk") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 13; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 4; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Fear (-2)", "Limited Movement", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: basilisk, weapon: venomous_spray) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: basilisk, special_rule: poison_burst) { |psr| psr.position = 0 }

carrion = Profile.find_or_create_by!(name: "Carrion") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 8; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 6; p.dexterity = 5; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Infiltration", "Mindless", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: carrion, weapon: implanted_tools) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: carrion, special_rule: nexus) { |psr| psr.position = 0 }

crocodile = Profile.find_or_create_by!(name: "Crocodile") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 14; p.movement = 3; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Fast Swimmer (3)", "Limited Movement", "Mindless", "Primitive", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: crocodile, weapon: enhanced_jaws) { |pw| pw.position = 0 }

doctor_of_venesection = Profile.find_or_create_by!(name: "Doctor of Venesection") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 9; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Frenzied", "Limited Movement", "Primitive", "Vampiric Attack (1)"]
end
ProfileWeapon.find_or_create_by!(profile: doctor_of_venesection, weapon: fangs) { |pw| pw.position = 0 }

diving_assistant = Profile.find_or_create_by!(name: "Diving Assistant") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 3; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Bodyguard (Doctor)", "Universal Shielding (2)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: diving_assistant, weapon: trident) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: diving_assistant, special_rule: deep_dive) { |psr| psr.position = 0 }

electron_cannoneer = Profile.find_or_create_by!(name: "Electron Cannoneer") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: electron_cannoneer, weapon: electron_cannon) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: electron_cannoneer, special_rule: volatile_arc_power) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: electron_cannoneer, special_rule: unstable) { |psr| psr.position = 1 }

ghoul = Profile.find_or_create_by!(name: "Ghoul") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 6; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 6; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Mindless", "Frenzied"]
end
ProfileWeapon.find_or_create_by!(profile: ghoul, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ghoul, special_rule: unstable_wretch) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ghoul, special_rule: bereft_of_will) { |psr| psr.position = 1 }

gorilla = Profile.find_or_create_by!(name: "Gorilla") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Bodyguard (Doctor)", "Flight", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: gorilla, weapon: titanic_fists) { |pw| pw.position = 0 }

hippocampus = Profile.find_or_create_by!(name: "Hippocampus") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 14; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 19; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Bulky", "Fast Swimmer (4)", "Limited Movement", "Mindless", "Primitive", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: hippocampus, weapon: hoof_stomp) { |pw| pw.position = 0 }

hippogryph = Profile.find_or_create_by!(name: "Hippogryph") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 7; p.movement = 6; p.dexterity = 5; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Flight", "Infiltration", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: hippogryph, weapon: beak_and_claws) { |pw| pw.position = 0 }

hollowman = Profile.find_or_create_by!(name: "Hollowman") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 6; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 6; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Frenzied", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: hollowman, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: hollowman, special_rule: blood_nexus) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: hollowman, special_rule: death_throes_overload) { |psr| psr.position = 1 }

harvester = Profile.find_or_create_by!(name: "Harvester") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Expert Grappler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: harvester, weapon: meat_hook) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: harvester, special_rule: shepherd) { |psr| psr.position = 0 }

husk = Profile.find_or_create_by!(name: "Husk") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 4; p.movement = 4; p.dexterity = 2; p.attack = 3; p.protection = 0; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Expert Grappler (2)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: husk, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: husk, special_rule: corpse) { |psr| psr.position = 0 }

lab_assistant = Profile.find_or_create_by!(name: "Lab Assistant") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Doctor)", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: lab_assistant, weapon: shock_prod) { |pw| pw.position = 0 }

lion = Profile.find_or_create_by!(name: "Lion") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 12; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Engage", "Expert Offence (3)", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: lion, weapon: ripping_teeth) { |pw| pw.position = 0 }

madman = Profile.find_or_create_by!(name: "Madman") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 8; p.will_points = 6; p.command_points = 0
  p.size = 30; p.ducats = 5; p.movement = 5; p.dexterity = 4; p.attack = 1; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: madman, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: madman, special_rule: nexus) { |psr| psr.position = 0 }

manticore = Profile.find_or_create_by!(name: "Manticore") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 6; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Expert Marksman (2)", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: manticore, weapon: quilled_spines) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: manticore, special_rule: spined_hide) { |psr| psr.position = 0 }

mermaid = Profile.find_or_create_by!(name: "Mermaid") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 11; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 3; p.dexterity = 5; p.attack = 3; p.protection = 1; p.mind = 1
  p.keywords = ["Henchman", "Discipline (Runes of Sovereignty)"]
  p.abilities = ["Fast Swimmer (3)", "Mage (0)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: mermaid, weapon: hidden_claws) { |pw| pw.position = 0 }

monstrosity = Profile.find_or_create_by!(name: "Monstrosity") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 14; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 9; p.movement = 4; p.dexterity = 2; p.attack = 3; p.protection = 0; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Brawler (1)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: monstrosity, weapon: rusty_blade) { |pw| pw.position = 0 }

nurse = Profile.find_or_create_by!(name: "Nurse") do |p|
  p.version = "2.3.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 10; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 7; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Frenzied", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: nurse, weapon: rusty_knife) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: nurse, special_rule: healer) { |psr| psr.position = 0 }

rhino = Profile.find_or_create_by!(name: "Rhino") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 20; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 15; p.movement = 5; p.dexterity = 3; p.attack = 3; p.protection = 5; p.mind = 1
  p.keywords = ["Henchman", "Animal"]
  p.abilities = ["Bulky", "First Strike (2)", "Limited Movement", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: rhino, weapon: horns) { |pw| pw.position = 0 }

shackled_feaster = Profile.find_or_create_by!(name: "Shackled Feaster") do |p|
  p.version = "2.2.0"; p.faction = "doctors"
  p.action_points = 2; p.life_points = 9; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 7; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Frenzied", "Mindless", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: shackled_feaster, weapon: tender_claws) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: shackled_feaster, special_rule: regenerating) { |psr| psr.position = 0 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Pages 26, 28, 30, 33, 37, 39, 40, 42, 46 produced _a/_b variants; _a is used.
{
  "Doctor of the Mind"             => ["p02.png", 3, -27, 100, false],
  "Master of Necromantic Studies"  => ["p03.png", 3, 3, 95, false],
  "Master of Arcane Security"      => ["p04.png", 22, 13, 105, false],
  "Master of Zoology"              => ["p05.png", 19, -6, 95, false],
  "Plague Doctor"                  => ["p06.png", 31, -20, 80, false],
  "Patient 42"                     => ["p07.png", -4, -12, 90, false],
  "The Being"                      => ["p08.png", 4, -11, 90, false],
  "The Unholy Union"               => ["p09.png", 1, -6, 95, false],
  "Brined Horror"                  => ["p10.png", 8, -11, 90, false],
  "Doctor of Blood"                => ["p11.png", -2, -20, 100, false],
  "Doctor of Divine Probabilities" => ["p12.png", 12, -24, 75, false],
  "Doctor of Tides"                => ["p13.png", 0, -3, 90, false],
  "Doctor of Poisons"              => ["p14.png", 51, -35, 75, false],
  "Doctor of the Beasts"           => ["p15.png", 31, -6, 80, false],
  "Doctor of the Firmament"        => ["p16.png", -22, -10, 110, true],
  "Ethereal Assassin"              => ["p17.png", 35, -22, 80, false],
  "Ethereal Snatcher"              => ["p18.png", 9, 2, 100, true],
  "Alchemist Doctor"               => ["p19.png", 22, -13, 90, false],
  "Morgue Doctor"                  => ["p20.png", -3, -11, 100, true],
  "Marine Biologist"               => ["p21.png", 14, -19, 95, true],
  "Ordnance Doctor"                => ["p22.png", -4, -21, 95, false],
  "Unleashed Madman"               => ["p23.png", 12, -25, 85, false],
  "Voltage Bombardiers"            => ["p24.png", 25, -2, 90, false],
  "Warden"                         => ["p25.png", -15, -5, 100, true],
  "Apprentice Doctor"              => ["p26_a.png", -25, -13, 85, false],
  "Basilisk"                       => ["p27.png", 23, -26, 90, false],
  "Carrion"                        => ["p28_a.png", 12, -47, 80, false],
  "Crocodile"                      => ["p29.png", 25, -44, 70, false],
  "Doctor of Venesection"          => ["p30_a.png", 62, -36, 70, false],
  "Diving Assistant"               => ["p31.png", -8, -18, 90, false],
  "Electron Cannoneer"             => ["p32.png", 10, -11, 90, false],
  "Ghoul"                          => ["p33_a.png", 15, -18, 95, false],
  "Gorilla"                        => "p34.png",
  "Hippocampus"                    => ["p35.png", 7, -27, 90, false],
  "Hippogryph"                     => ["p36.png", -22, 41, 100, false],
  "Hollowman"                      => ["p37_a.png", 50, -19, 75, false],
  "Harvester"                      => ["p38.png", 4, -18, 80, true],
  "Husk"                           => ["p39_a.png", 18, -35, 90, false],
  "Lab Assistant"                  => ["p40_a.png", -6, 4, 100, false],
  "Lion"                           => ["p41.png", 29, -27, 85, true],
  "Madman"                         => ["p42_a.png", 24, -35, 80, false],
  "Manticore"                      => ["p43.png", 33, -17, 90, false],
  "Mermaid"                        => ["p44.png", 64, -23, 80, false],
  "Monstrosity"                    => ["p45.png", 14, -16, 115, false],
  "Nurse"                          => ["p46_a.png", 31, -19, 80, false],
  "Rhino"                          => ["p47.png", 23, -29, 90, false],
  "Shackled Feaster"               => ["p48.png", -11, -22, 85, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "doctors", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Apprentice Doctor"     => "p26_b.png",
  "Carrion"               => ["p28_b.png", 17, -32, 80, false],
  "Doctor of Venesection" => ["p30_b.png", 27, -1, 80, false],
  "Ghoul"                 => ["p33_b.png", 18, -17, 90, false],
  "Hollowman"             => "p37_b.png",
  "Husk"                  => ["p39_b.png", -2, -32, 85, false],
  "Lab Assistant"         => "p40_b.png",
  "Madman"                => ["p42_b.png", 21, -31, 70, false],
  "Nurse"                 => ["p46_b.png", 38, 10, 70, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "doctors", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end
