# ── Card References ────────────────────────────────────────────────────────────
card_ref_data = [
  { name: "Il Capitano",            identifier: "gifted-il-capitano",           cost: 19 },
  { name: "La Signora",             identifier: "gifted-la-signora",            cost: 18 },
  { name: "The Duke",               identifier: "gifted-the-duke",              cost: 22 },
  { name: "The Aberration",         identifier: "gifted-the-aberration",        cost: 23 },
  { name: "Artisan Elena",          identifier: "gifted-artisan-elena",         cost: 17 },
  { name: "Black Spectre",          identifier: "gifted-black-spectre",         cost: 30 },
  { name: "Burattino",              identifier: "gifted-burattino",             cost: 15 },
  { name: "Fadhila",                identifier: "gifted-fadhila",               cost: 19 },
  { name: "Fate",                   identifier: "gifted-fate",                  cost: 18 },
  { name: "Francisco De Lorme",     identifier: "gifted-francisco-de-lorme",    cost: 16 },
  { name: "Harbinger's Reflection", identifier: "gifted-harbingers-reflection", cost: 17 },
  { name: "Harlequin",              identifier: "gifted-harlequin",             cost: 18 },
  { name: "Il Mentore",             identifier: "gifted-il-mentore",            cost: 16 },
  { name: "Innamorati",             identifier: "gifted-innamorati",            cost: 13 },
  { name: "Justice",                identifier: "gifted-justice",               cost: 18 },
  { name: "Marco Leontus",          identifier: "gifted-marco-leontus",         cost: 15 },
  { name: "Master Gerhard",         identifier: "gifted-master-gerhard",        cost: 16 },
  { name: "Maria Fioritura",        identifier: "gifted-maria-fioritura",       cost: 18 },
  { name: "Painted Protector",      identifier: "gifted-painted-protector",     cost:  0 },
  { name: "Senshi the Undying",     identifier: "gifted-senshi-the-undying",    cost: 20 },
  { name: "Solus Hydraea",          identifier: "gifted-solus-hydraea",         cost: 17 },
  { name: "The Mask Maker",         identifier: "gifted-the-mask-maker",        cost: 14 },
  { name: "White Dove",             identifier: "gifted-white-dove",            cost: 21 },
  { name: "Zovena Vela",            identifier: "gifted-zovena-vela",           cost: 15 },
  { name: "Brighella",              identifier: "gifted-brighella",             cost: 13 },
  { name: "Colombina",              identifier: "gifted-colombina",             cost: 10 },
  { name: "Coviello",               identifier: "gifted-coviello",              cost: 11 },
  { name: "The Demolitionist",      identifier: "gifted-the-demolitionist",     cost: 13 },
  { name: "Escaped Madman",         identifier: "gifted-escaped-madman",        cost: 16 },
  { name: "Il Dottore",             identifier: "gifted-il-dottore",            cost: 12 },
  { name: "Mezzetino",              identifier: "gifted-mezzetino",             cost: 13 },
  { name: "Pantaleone",             identifier: "gifted-pantaleone",            cost: 10 },
  { name: "Scapino",                identifier: "gifted-scapino",               cost:  0 },
  { name: "Starspawn",              identifier: "gifted-starspawn",             cost: 15 },
  { name: "Pierrot",                identifier: "gifted-pierrot-a",             cost:  8 },
  { name: "Pierrot",                identifier: "gifted-pierrot-b",             cost:  8 },
]


# Gifted faction seeds — all 35 profiles.
# Idempotent — safe to run multiple times. Load from db/seeds.rb.
# The Gifted are mercenaries: "Any character with the Faction (Gifted) keyword can
# be taken in any gang." Faction-wide ability "What's My Cue?" is not a profile.

# Shared clause printed on every Mask-granting ability.
mask_restriction = "A character can only be given a single Mask. Unique characters without Faction (Gifted) and Mindless characters cannot be given a Mask."

# ── Special Rules ──────────────────────────────────────────────────────────────

stage_manager = Catalog::SpecialRule.find_or_create_by!(name: "Stage Manager") do |r|
  r.description = "PULSE Command Ability. 2 friendly characters within line of sight may make an immediate Run/Climb action. This movement cannot be used to move into or out of base contact with an enemy."
end
troupe_leader = Catalog::SpecialRule.find_or_create_by!(name: "Troupe Leader") do |r|
  r.description = "All friendly characters with the Commedia dell'Arte keyword gain Companion (Il Capitano) as long as this character is on the board. Remember, that Companion characters must use the MIND value of their Companion, even if its lower (only Il Capitano thinks he's a great leader)."
end
search_of_satisfaction = Catalog::SpecialRule.find_or_create_by!(name: "Search of Satisfaction") do |r|
  r.description = "PULSE Command Ability. Add up every character (friendly or enemy) within 3\" of this character. She replenishes that many Will Points."
end
cheat = Catalog::SpecialRule.find_or_create_by!(name: "Cheat") do |r|
  r.description = "If this is the only character with the Leader keyword in the gang, this character loses the Hero keyword. However, if the gang contains Il Capitano, this character loses the Leader keyword."
end
all_eyes_on_me = Catalog::SpecialRule.find_or_create_by!(name: "All Eyes On Me") do |r|
  r.description = "For every friendly character in line of sight to this character (including this character) at the start of the round, add a re-roll to your All Eyes On Me Pool. Until the end of the round, any friendly character may use these re-rolls on any roll - one re-roll per dice."
end
disappear = Catalog::SpecialRule.find_or_create_by!(name: "Disappear - 2AP") do |r|
  r.description = "If this character is in base contact with any enemy characters, it may Disappear in a cloud of smoke. All characters in base contact are counted as being hit with a weapon with the Smoke ability. Place the Duke anywhere out of base contact within 12\". This does not cause Attacks of Opportunity."
end
inspiring_hero = Catalog::SpecialRule.find_or_create_by!(name: "Inspiring Hero") do |r|
  r.description = "If this is the only character with the Leader keyword in the gang, this character loses the Hero keyword. However, if there is another character with the Leader keyword, this character loses the Leader keyword."
end
slavering_horror = Catalog::SpecialRule.find_or_create_by!(name: "Slavering Horror") do |r|
  r.description = "When this character makes Combat, Drown, or Grapple actions, it may re-roll any failed dice rolls (remember, you cannot re-roll the Destiny dice). Yes, even against Brave characters!"
end
fanged_visage = Catalog::SpecialRule.find_or_create_by!(name: "Fanged Visage") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character gains one of the following: Frenzied and Vampiric Attack (2) but reduce Will Points to 0; or First Strike (1) and Vampiric Attack (1). #{mask_restriction}"
end
supernatural = Catalog::SpecialRule.find_or_create_by!(name: "Supernatural") do |r|
  r.description = "When making Protection Rolls against Spectral Touch, the target must use their MIND value instead of their PROTECTION value. If the character failed their Fear test, they must re-roll any Aces."
end
diminutive = Catalog::SpecialRule.find_or_create_by!(name: "Diminutive") do |r|
  r.description = "This character counts all base sizes as larger than it. This affects Hunter, Grappling, and Drowning, for example."
end
protective_bubble = Catalog::SpecialRule.find_or_create_by!(name: "Protective Bubble - 1AP") do |r|
  r.description = "Pick a number from 1-6. Until the end of the round, any characters (friendly and enemy) gain Universal Shielding (4) and Expert Protection (4) while within that many inches of Fadhila."
end
the_other_side_of_the_coin = Catalog::SpecialRule.find_or_create_by!(name: "The Other Side of the Coin - 1AP") do |r|
  r.description = "If both Fate and Justice are on the board (as friendly characters), swap their positions."
end
aura_of_inevitability = Catalog::SpecialRule.find_or_create_by!(name: "Aura of Inevitability - 1AP") do |r|
  r.description = "Pick an enemy character in line of sight within 6\" and make an Opposed Mind Roll. If successful, the target loses 2 Will Points and 2 Life Points, and this character replenishes 2 Will Points."
end
take_the_oath = Catalog::SpecialRule.find_or_create_by!(name: "Take the Oath") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character increases their starting Will Points by 2 and gains Companion (Francisco De Lorme). Any friendly character within 6\" and line of sight of them may use that character's Will Points as if they were their own. #{mask_restriction}"
end
a_light_in_the_dark = Catalog::SpecialRule.find_or_create_by!(name: "A Light in the Dark") do |r|
  r.description = "Every time another character uses 2 of their own Will Points (and not those from other characters) in a single action, this character replenishes 2 Will Points. Additionally, this character may use more than 2 Will Points to increase a roll."
end
reflected_reality = Catalog::SpecialRule.find_or_create_by!(name: "Reflected Reality") do |r|
  r.description = "Unless this character has been killed, every time you draw any Agendas, draw one extra, take a look, and then discard one."
end
mischievous = Catalog::SpecialRule.find_or_create_by!(name: "Mischievous") do |r|
  r.description = "Whenever an enemy character uses a Will Point within 3\" of this character, roll a dice. On a 7+ the Will Point is still discarded, but there is no effect."
end
maximum_fastness = Catalog::SpecialRule.find_or_create_by!(name: "Maximum Fastness") do |r|
  r.description = "This character cannot have more than a +1 modifier to its DEXTERITY (e.g. due to Evasion or Reactions). Dice gained through spending Will Points are unaffected."
end
mask_of_many_faces = Catalog::SpecialRule.find_or_create_by!(name: "Mask of Many Faces") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character gains one of the following: Pickpocket and Slippery (2); or Aerial Attack and Infiltrate. #{mask_restriction}"
end
till_death_do_us_part = Catalog::SpecialRule.find_or_create_by!(name: "Till Death Do Us Part") do |r|
  r.description = "When this character is reduced to 5 Life Points or less, it gains +2 ATTACK and Mindless."
end
justice_served = Catalog::SpecialRule.find_or_create_by!(name: "Justice Served") do |r|
  r.description = "During deployment, pick 1 enemy character. Justice re-rolls all failed dice rolls when making Combat actions against this character, including the Destiny Dice!"
end
the_mask_makes_the_noble = Catalog::SpecialRule.find_or_create_by!(name: "The Mask Makes the Noble") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character gains one of the following: Increase their starting Command Points by 2; or Boat Crew and Bodyguard (Leader). #{mask_restriction}"
end
armourer = Catalog::SpecialRule.find_or_create_by!(name: "Armourer") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character gains one of the following: Universal Shielding (2); or whenever that character makes a Combat action against a character with 0 Will Points remaining, if the attack deals at least 1 Damage, increase the damage caused by 1 (before any PROTECTION rolls). #{mask_restriction}"
end
creative_creation = Catalog::SpecialRule.find_or_initialize_by(spell_name: "Creative Creation").tap do |r|
  r.name             = ""
  r.description      = "Maria Fioritura may use the following unique Magic Spell. This spell cannot be used by other characters. She knows this in addition to any other spells."
  r.spell_cost       = 2
  r.spell_difficulty = 7
  r.spell_description = "Place 1 Painted Protector anywhere within 3\" of this character. A Painted Protector counts as a friendly character and may take a turn that round as normal."
  r.save!
end
watered_down = Catalog::SpecialRule.find_or_create_by!(name: "Watered Down") do |r|
  r.description = "At the end of the round, if this character is in water, it is killed."
end
work_of_art = Catalog::SpecialRule.find_or_create_by!(name: "Work of Art") do |r|
  r.description = "This character cannot be chosen as part of a gang, and gives no Victory Points if killed. In addition, if this character is killed, the Maria Fioritura that created it replenishes 1 Will Point."
end
undying_deathseeker = Catalog::SpecialRule.find_or_create_by!(name: "Undying Deathseeker") do |r|
  r.description = "When this character is killed, do not remove it from the board, it remains in play but cannot be targeted or chosen. At the start of the next round, make a Basic MIND Roll (Will Points may be used as normal). If successful, this character comes back to life with 7 Life Points. If the MIND Roll is unsuccessful, the character is completely dead and removed from the board."
end
ronin = Catalog::SpecialRule.find_or_create_by!(name: "Ronin") do |r|
  r.description = "This character cannot receive ORDER or COUNTER Commands."
end
hofuku_kogeki = Catalog::SpecialRule.find_or_create_by!(name: "Hōfuku Kōgeki") do |r|
  r.description = "If this character's Undying Deathseeker roll is a critical, it may make either a 0AP Attack of Opportunity against an enemy character in base contact, or it may make a 0AP Run/Climb action, but must end this action in base contact with an enemy character."
end
mask_of_dagon = Catalog::SpecialRule.find_or_create_by!(name: "Mask of Dagon") do |r|
  r.description = "At the beginning of the game, before deployment, select another friendly character to wear one of this character's Masks. For the entirety of the game that character gains one of the following: Water Creature and the Monster keyword; or Fear (0) and +1 ATTACK. #{mask_restriction}"
end
split_personalities = Catalog::SpecialRule.find_or_create_by!(name: "Split Personalities") do |r|
  r.description = "At the start of this character's turn, he puts on a mask. Pick one of the following for the Mask Maker to gain until the start of his next turn: Fear (-2); Slippery; Vampiric Attack (2); Water Creature."
end
blinding_flash = Catalog::SpecialRule.find_or_create_by!(name: "Blinding Flash - 2AP") do |r|
  r.description = "Place the Blast marker on White Dove. Every enemy character at least partially touched by it receives a Stunned counter."
end
self_immolate = Catalog::SpecialRule.find_or_create_by!(name: "Self-Immolate") do |r|
  r.description = "When making a Combat action with Fiery Explosion, centre the Blast marker on Zovena Vela herself. She is hit by this attack like anyone else touched by the marker."
end
always_scheming = Catalog::SpecialRule.find_or_create_by!(name: "Always Scheming") do |r|
  r.description = "When a friendly character with the Leader keyword uses a Command while in line of sight, Brighella gains 1AP until the end of the round. Remember that no character can use more than 3AP in one round!"
end
all_according_to_plan = Catalog::SpecialRule.find_or_create_by!(name: "All According to Plan") do |r|
  r.description = "Colombina has a plan, and provided everyone plays their role, it'll all work out in the end. Once per round, when any character with line of sight to this character (including herself) is about to make a roll with at least 1 dice, you can decide to score a single Ace instead of rolling."
end
annoying_tune = Catalog::SpecialRule.find_or_create_by!(name: "Annoying Tune") do |r|
  r.description = "All enemy characters have -1 DEXTERITY while within 3\" of Coviello. However, all enemy characters within 3\" may re-roll 1 failed dice roll in Combat actions when Coviello is the target."
end
deathwish = Catalog::SpecialRule.find_or_create_by!(name: "Deathwish") do |r|
  r.description = "This character may not make Unarmed Combat actions. Additionally, any failed Combat actions with Bombs always count as fumbles."
end
shattered_nexus = Catalog::SpecialRule.find_or_create_by!(name: "Shattered Nexus") do |r|
  r.description = "When this character is reduced to 0 Will Points, after the current action is finished, place the Blast Marker over its head. Every character under the marker (including this one) takes 3 Damage, with Protection Rolls as normal. If this character survives, it replenishes 3 Will Points."
end
bored_to_inaction = Catalog::SpecialRule.find_or_create_by!(name: "Bored to Inaction") do |r|
  r.description = "Any character (friendly or enemy) within 3\" of Il Dottore must listen to him drone on. These characters do not benefit from any Commands used on them, including any Command Abilities they may be in range of. Il Dottore finds himself extremely interesting, and so can be the target of Commands as normal."
end
vindictive = Catalog::SpecialRule.find_or_create_by!(name: "Vindictive") do |r|
  r.description = "If an enemy character causes damage to Mezzetino (before Protection Rolls), he may re-roll any failed dice rolls for Combat actions against that character for the rest of the game, including the Destiny Dice."
end
hoarded_wealth = Catalog::SpecialRule.find_or_create_by!(name: "Hoarded Wealth") do |r|
  r.description = "At the end of each round, if this character hasn't used any Will Points during that round, he gains 1 Will Point. This can take him above his starting number."
end
confusing_exit = Catalog::SpecialRule.find_or_create_by!(name: "Confusing Exit") do |r|
  r.description = "When this character successfully disengages, any enemy characters that were in base contact receive a Stunned counter."
end
thirsty = Catalog::SpecialRule.find_or_create_by!(name: "Thirsty") do |r|
  r.description = "Any time a friendly or enemy character successfully casts a Magic Spell, after resolving all effects, this character replenishes 1 Will Point."
end
everyman = Catalog::SpecialRule.find_or_create_by!(name: "Everyman") do |r|
  r.description = "If a friendly character is charged within 6\" of one or more characters with this rule, you may choose to swap them with one friendly Pierrot that isn't in base contact with an enemy. This is done before any Attacks of Opportunity. Turns out it was Pierrot all along!"
end

# ── Weapons ───────────────────────────────────────────────────────────────────

greatsword       = Catalog::Weapon.find_or_create_by!(name: "Greatsword")       { |w| w.range = 1;  w.evasion = 0;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Two-handed"] }
costume_pistol   = Catalog::Weapon.find_or_create_by!(name: "Costume Pistol")   { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Black Powder", "Harmless", "Knockback"] }
rapier           = Catalog::Weapon.find_or_create_by!(name: "Rapier")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
pistol           = Catalog::Weapon.find_or_create_by!(name: "Pistol")           { |w| w.range = 8;  w.evasion = 1;  w.damage = 0;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
sword            = Catalog::Weapon.find_or_create_by!(name: "Sword")            { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
monstrous_tentacles = Catalog::Weapon.find_or_create_by!(name: "Monstrous Tentacles") { |w| w.range = 3; w.evasion = 1; w.damage = 1; w.penetration = 0; w.abilities = ["Stun"] }
spectral_touch   = Catalog::Weapon.find_or_create_by!(name: "Spectral Touch")   { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
carving_knife    = Catalog::Weapon.find_or_create_by!(name: "Carving Knife")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
unarmed          = Catalog::Weapon.find_or_create_by!(name: "Unarmed")          { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }
book_of_destiny  = Catalog::Weapon.find_or_create_by!(name: "Book of Destiny")  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
shattered_touch  = Catalog::Weapon.find_or_create_by!(name: "Shattered Touch")  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -4; w.abilities = [] }
stiletto         = Catalog::Weapon.find_or_create_by!(name: "Stiletto")         { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 1;  w.abilities = [] }
sword_of_balance = Catalog::Weapon.find_or_create_by!(name: "Sword of Balance") { |w| w.range = 1;  w.evasion = 0;  w.damage = 1;  w.penetration = -4; w.abilities = ["Two-handed"] }
forge_hammer     = Catalog::Weapon.find_or_create_by!(name: "Forge Hammer")     { |w| w.range = 0;  w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
paintbrush       = Catalog::Weapon.find_or_create_by!(name: "Paintbrush")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }
daisho           = Catalog::Weapon.find_or_create_by!(name: "Daishō")           { |w| w.range = 0;  w.evasion = -1; w.damage = 1;  w.penetration = -1; w.abilities = [] }
bronze_chisel    = Catalog::Weapon.find_or_create_by!(name: "Bronze Chisel")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
pliers           = Catalog::Weapon.find_or_create_by!(name: "Pliers")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
doves_kiss       = Catalog::Weapon.find_or_create_by!(name: "Dove's Kiss")      { |w| w.range = 8;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Knockback", "Reload (2)"] }
fireball         = Catalog::Weapon.find_or_create_by!(name: "Fireball")         { |w| w.range = 8;  w.evasion = 0;  w.damage = 2;  w.penetration = -2; w.abilities = ["Black Powder", "Two-handed", "Reload (2)"] }
fiery_explosion  = Catalog::Weapon.find_or_create_by!(name: "Fiery Explosion")  { |w| w.range = 0;  w.evasion = 0;  w.damage = 2;  w.penetration = -7; w.abilities = ["Black Powder", "Blast", "Reload (1)"] }
atrezzo_crossbow = Catalog::Weapon.find_or_create_by!(name: "Atrezzo Crossbow") { |w| w.range = 30; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Reload (2)", "Two-handed"] }
gilded_mirror    = Catalog::Weapon.find_or_create_by!(name: "Gilded Mirror")    { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
prop_sword       = Catalog::Weapon.find_or_create_by!(name: "Prop Sword")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
bomb             = Catalog::Weapon.find_or_create_by!(name: "Bomb")             { |w| w.range = 6;  w.evasion = 1;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Black Powder", "Blast", "Reload (1)"] }
tentacled_rebar  = Catalog::Weapon.find_or_create_by!(name: "Tentacled Rebar")  { |w| w.range = 1;  w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Knockback"] }
wine_bottle      = Catalog::Weapon.find_or_create_by!(name: "Wine Bottle")      { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
smoke_bomb       = Catalog::Weapon.find_or_create_by!(name: "Smoke Bomb")       { |w| w.range = 6;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Blast", "Harmless", "Smoke", "Reload (1)"] }
fanged_tentacles = Catalog::Weapon.find_or_create_by!(name: "Fanged Tentacles") { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic"] }

# "Claws" (Artisan Elena) and "Scalpel" (Francisco De Lorme) collide by name with
# weapons from other factions that have different stats. Disambiguate so each
# profile links to the correct stat line (no name uniqueness constraint exists).
# Elena's Claws has no Aquatic, unlike the Rashaar "Claws" — distinguish on abilities.
claws_gifted = Catalog::Weapon.where(name: "Claws").detect { |w| w.abilities == [] } ||
               Catalog::Weapon.create!(name: "Claws", range: 0, evasion: 0, damage: 0, penetration: -1, abilities: [])
# Francisco's Scalpel is penetration 0, unlike the Doctors' Scalpel (penetration -1).
scalpel_gifted = Catalog::Weapon.find_or_create_by!(name: "Scalpel", penetration: 0) { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.abilities = [] }

# ── Leaders ───────────────────────────────────────────────────────────────────

il_capitano = Catalog::Profile.find_or_create_by!(name: "Il Capitano") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 13; p.will_points = 3; p.command_points = 4
  p.size = 30; p.ducats = 19; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["Leader", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Brawler (2)", "Expert Offence (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: il_capitano, weapon: greatsword) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: il_capitano, special_rule: stage_manager) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: il_capitano, special_rule: troupe_leader) { |psr| psr.position = 1 }

la_signora = Catalog::Profile.find_or_create_by!(name: "La Signora") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 15; p.will_points = 5; p.command_points = 3
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Leader", "Hero", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Bulky", "Parry (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: la_signora, weapon: costume_pistol) { |pw| pw.position = 0 }
Catalog::ProfileWeapon.find_or_create_by!(profile: la_signora, weapon: rapier)         { |pw| pw.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: la_signora, special_rule: search_of_satisfaction) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: la_signora, special_rule: cheat)          { |psr| psr.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: la_signora, special_rule: all_eyes_on_me) { |psr| psr.position = 2 }

the_duke = Catalog::Profile.find_or_create_by!(name: "The Duke") do |p|
  p.version = "2.2.1"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 13; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 22; p.movement = 4; p.dexterity = 5; p.attack = 5; p.protection = 4; p.mind = 5
  p.keywords = ["Leader", "Hero", "Unique"]
  p.abilities = ["Aerial Attack", "Bodyguard (Henchman)", "Expert Offence (2)", "Infiltration"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: the_duke, weapon: pistol) { |pw| pw.position = 0 }
Catalog::ProfileWeapon.find_or_create_by!(profile: the_duke, weapon: sword)  { |pw| pw.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: the_duke, special_rule: disappear)      { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: the_duke, special_rule: inspiring_hero) { |psr| psr.position = 1 }

# ── Heroes ────────────────────────────────────────────────────────────────────

the_aberration = Catalog::Profile.find_or_create_by!(name: "The Aberration") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 22; p.will_points = 4; p.command_points = 0
  p.size = 50; p.ducats = 23; p.movement = 4; p.dexterity = 4; p.attack = 5; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Berserk", "Bulky", "Mindless"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: the_aberration, weapon: monstrous_tentacles) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: the_aberration, special_rule: slavering_horror) { |psr| psr.position = 0 }

artisan_elena = Catalog::Profile.find_or_create_by!(name: "Artisan Elena") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Hero", "Unique", "Vampire"]
  p.abilities = ["Vampiric Attack (1)", "Frenzied"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: artisan_elena, weapon: claws_gifted) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: artisan_elena, special_rule: fanged_visage) { |psr| psr.position = 0 }

black_spectre = Catalog::Profile.find_or_create_by!(name: "Black Spectre") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 30; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 30; p.movement = 4; p.dexterity = 4; p.attack = 6; p.protection = 2; p.mind = 3
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Bulky", "Ethereal", "Fear (-2)", "Flight", "Mindless"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: black_spectre, weapon: spectral_touch) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: black_spectre, special_rule: supernatural) { |psr| psr.position = 0 }

burattino = Catalog::Profile.find_or_create_by!(name: "Burattino") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 1; p.mind = 3
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Engage", "Expert Offence (3)", "Hunter", "Mindless", "Vampiric Attack (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: burattino, weapon: carving_knife) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: burattino, special_rule: diminutive) { |psr| psr.position = 0 }

fadhila = Catalog::Profile.find_or_create_by!(name: "Fadhila") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 12; p.will_points = 6; p.command_points = 0
  p.size = 30; p.ducats = 19; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 4; p.mind = 5
  p.keywords = ["Hero", "Unique", "Discipline (Divinity, Fateweaving)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: fadhila, weapon: unarmed) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: fadhila, special_rule: protective_bubble) { |psr| psr.position = 0 }

fate = Catalog::Profile.find_or_create_by!(name: "Fate") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 14; p.will_points = 5; p.command_points = 0
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 5
  p.keywords = ["Hero", "Unique", "Discipline (Runes of Sovereignty, Blood Rites, Fateweaving)"]
  p.abilities = ["Ethereal", "Expert Sorcerer (2)", "Mage (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: fate, weapon: book_of_destiny) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: fate, special_rule: the_other_side_of_the_coin) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: fate, special_rule: aura_of_inevitability)      { |psr| psr.position = 1 }

francisco_de_lorme = Catalog::Profile.find_or_create_by!(name: "Francisco De Lorme") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Unique", "Discipline (Blood Rites, Wild Magic)"]
  p.abilities = ["Mage (1)", "Expert Sorcerer (1)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: francisco_de_lorme, weapon: scalpel_gifted) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: francisco_de_lorme, special_rule: take_the_oath) { |psr| psr.position = 0 }

harbingers_reflection = Catalog::Profile.find_or_create_by!(name: "Harbinger's Reflection") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 3; p.mind = 6
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Ethereal", "Mindless", "Universal Shielding (3)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: harbingers_reflection, weapon: shattered_touch) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: harbingers_reflection, special_rule: a_light_in_the_dark) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: harbingers_reflection, special_rule: reflected_reality)   { |psr| psr.position = 1 }

harlequin = Catalog::Profile.find_or_create_by!(name: "Harlequin") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 18; p.movement = 5; p.dexterity = 7; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["Hero", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Acrobatic (3)", "Slippery"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: harlequin, weapon: sword) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: harlequin, special_rule: mischievous)      { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: harlequin, special_rule: maximum_fastness) { |psr| psr.position = 1 }

il_mentore = Catalog::Profile.find_or_create_by!(name: "Il Mentore") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Unique", "Trade"]
  p.abilities = ["Slippery (2)", "Pickpocket"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: il_mentore, weapon: stiletto) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: il_mentore, special_rule: mask_of_many_faces) { |psr| psr.position = 0 }

innamorati = Catalog::Profile.find_or_create_by!(name: "Innamorati") do |p|
  p.version = "2.2.1"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 12; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Hero", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Parry (1)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: innamorati, weapon: pistol) { |pw| pw.position = 0 }
Catalog::ProfileWeapon.find_or_create_by!(profile: innamorati, weapon: sword)  { |pw| pw.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: innamorati, special_rule: till_death_do_us_part) { |psr| psr.position = 0 }

justice = Catalog::Profile.find_or_create_by!(name: "Justice") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 14; p.will_points = 5; p.command_points = 0
  p.size = 30; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Ethereal"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: justice, weapon: sword_of_balance) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: justice, special_rule: the_other_side_of_the_coin) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: justice, special_rule: justice_served)             { |psr| psr.position = 1 }

marco_leontus = Catalog::Profile.find_or_create_by!(name: "Marco Leontus") do |p|
  p.version = "2.3.1"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Unique"]
  p.abilities = []
end
Catalog::ProfileWeapon.find_or_create_by!(profile: marco_leontus, weapon: pistol) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: marco_leontus, special_rule: the_mask_makes_the_noble) { |psr| psr.position = 0 }

master_gerhard = Catalog::Profile.find_or_create_by!(name: "Master Gerhard") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Universal Shielding (3)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: master_gerhard, weapon: forge_hammer) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: master_gerhard, special_rule: armourer) { |psr| psr.position = 0 }

maria_fioritura = Catalog::Profile.find_or_create_by!(name: "Maria Fioritura") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 6; p.command_points = 0
  p.size = 30; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique", "Discipline (Runes of Sovereignty, Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: maria_fioritura, weapon: paintbrush) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: maria_fioritura, special_rule: creative_creation) { |psr| psr.position = 0 }

painted_protector = Catalog::Profile.find_or_create_by!(name: "Painted Protector") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 0; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 6; p.mind = 1
  p.keywords = []
  p.abilities = ["Expert Protection (2)", "Universal Shielding (4)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: painted_protector, weapon: sword) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: painted_protector, special_rule: watered_down) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: painted_protector, special_rule: work_of_art)   { |psr| psr.position = 1 }

senshi = Catalog::Profile.find_or_create_by!(name: "Senshi the Undying") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 14; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 20; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Acrobatic (2)", "Expert Offence (2)", "First Strike (1)", "Parry (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: senshi, weapon: daisho) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: senshi, special_rule: undying_deathseeker) { |psr| psr.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: senshi, special_rule: ronin)               { |psr| psr.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: senshi, special_rule: hofuku_kogeki)       { |psr| psr.position = 2 }

solus_hydraea = Catalog::Profile.find_or_create_by!(name: "Solus Hydraea") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Fear (0)", "Water Creature"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: solus_hydraea, weapon: bronze_chisel) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: solus_hydraea, special_rule: mask_of_dagon) { |psr| psr.position = 0 }

mask_maker = Catalog::Profile.find_or_create_by!(name: "The Mask Maker") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 5; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Concealment (+1)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: mask_maker, weapon: pliers) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: mask_maker, special_rule: split_personalities) { |psr| psr.position = 0 }

white_dove = Catalog::Profile.find_or_create_by!(name: "White Dove") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 3; p.life_points = 14; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 21; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Expert Marksman (2)", "Flight"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: white_dove, weapon: doves_kiss) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: white_dove, special_rule: blinding_flash) { |psr| psr.position = 0 }

zovena_vela = Catalog::Profile.find_or_create_by!(name: "Zovena Vela") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Brave", "Pickpocket", "Slippery"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: zovena_vela, weapon: fireball)        { |pw| pw.position = 0 }
Catalog::ProfileWeapon.find_or_create_by!(profile: zovena_vela, weapon: fiery_explosion) { |pw| pw.position = 1 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: zovena_vela, special_rule: self_immolate) { |psr| psr.position = 0 }

# ── Henchmen ──────────────────────────────────────────────────────────────────

brighella = Catalog::Profile.find_or_create_by!(name: "Brighella") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Expert Marksman (1)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: brighella, weapon: atrezzo_crossbow) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: brighella, special_rule: always_scheming) { |psr| psr.position = 0 }

colombina = Catalog::Profile.find_or_create_by!(name: "Colombina") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 5
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = []
end
Catalog::ProfileWeapon.find_or_create_by!(profile: colombina, weapon: gilded_mirror) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: colombina, special_rule: all_according_to_plan) { |psr| psr.position = 0 }

coviello = Catalog::Profile.find_or_create_by!(name: "Coviello") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Acrobatic (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: coviello, weapon: prop_sword) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: coviello, special_rule: annoying_tune) { |psr| psr.position = 0 }

demolitionist = Catalog::Profile.find_or_create_by!(name: "The Demolitionist") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Unique"]
  p.abilities = ["Berserk", "Expert Marksman (2)", "Mindless"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: demolitionist, weapon: bomb) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: demolitionist, special_rule: deathwish) { |psr| psr.position = 0 }

escaped_madman = Catalog::Profile.find_or_create_by!(name: "Escaped Madman") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 14; p.will_points = 3; p.command_points = 0
  p.size = 40; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Unique"]
  p.abilities = ["Expert Grappler (3)", "Mindless"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: escaped_madman, weapon: tentacled_rebar) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: escaped_madman, special_rule: shattered_nexus) { |psr| psr.position = 0 }

il_dottore = Catalog::Profile.find_or_create_by!(name: "Il Dottore") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Engage"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: il_dottore, weapon: wine_bottle) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: il_dottore, special_rule: bored_to_inaction) { |psr| psr.position = 0 }

mezzetino = Catalog::Profile.find_or_create_by!(name: "Mezzetino") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Parry (1)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: mezzetino, weapon: sword) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: mezzetino, special_rule: vindictive) { |psr| psr.position = 0 }

pantaleone = Catalog::Profile.find_or_create_by!(name: "Pantaleone") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Pickpocket"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: pantaleone, weapon: smoke_bomb) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: pantaleone, special_rule: hoarded_wealth) { |psr| psr.position = 0 }

scapino = Catalog::Profile.find_or_create_by!(name: "Scapino") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 5; p.dexterity = 5; p.attack = 2; p.protection = 2; p.mind = 3
  p.keywords = ["Henchman", "Unique", "Commedia dell'Arte"]
  p.abilities = ["Slippery"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: scapino, weapon: unarmed) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: scapino, special_rule: confusing_exit) { |psr| psr.position = 0 }

starspawn = Catalog::Profile.find_or_create_by!(name: "Starspawn") do |p|
  p.version = "2.3.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 14; p.will_points = 3; p.command_points = 0
  p.size = 40; p.ducats = 15; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman", "Unique"]
  p.abilities = ["Mindless", "Primitive", "Vampiric Attack (2)"]
end
Catalog::ProfileWeapon.find_or_create_by!(profile: starspawn, weapon: fanged_tentacles) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: starspawn, special_rule: thirsty) { |psr| psr.position = 0 }

pierrot = Catalog::Profile.find_or_create_by!(name: "Pierrot") do |p|
  p.version = "2.2.0"; p.faction = "gifted"
  p.action_points = 2; p.life_points = 8; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["Henchman", "Commedia dell'Arte"]
  p.abilities = []
end
Catalog::ProfileWeapon.find_or_create_by!(profile: pierrot, weapon: unarmed) { |pw| pw.position = 0 }
Catalog::ProfileSpecialRule.find_or_create_by!(profile: pierrot, special_rule: everyman) { |psr| psr.position = 0 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Page 36 produced _a through _g variants (Pierrot is a multi-copy henchman); _a is used.
{
  "Il Capitano"           => ["p02.png", 1, -5, 105, false],
  "La Signora"            => ["p03.png", 13, -17, 90, false],
  "The Duke"              => ["p04.png", -2, -11, 75, false],
  "The Aberration"        => ["p05.png", 5, -13, 95, false],
  "Artisan Elena"         => ["p06.png", 22, -15, 80, false],
  "Black Spectre"         => "p07.png",
  "Burattino"             => ["p08.png", 29, -23, 80, false],
  "Fadhila"               => ["p09.png", 5, 4, 160, false],
  "Fate"                  => ["p10.png", -6, -4, 100, false],
  "Francisco De Lorme"    => ["p11.png", -2, -5, 110, false],
  "Harbinger's Reflection" => ["p12.png", 2, -19, 95, true],
  "Harlequin"             => ["p13.png", 12, 30, 110, false],
  "Il Mentore"            => ["p14.png", 21, -28, 85, false],
  "Innamorati"            => ["p15.png", -12, -15, 105, false],
  "Justice"               => ["p16.png", 0, -7, 95, false],
  "Marco Leontus"         => ["p17.png", 17, -17, 85, false],
  "Master Gerhard"        => ["p18.png", 5, -14, 95, false],
  "Maria Fioritura"       => ["p19.png", -3, -8, 115, false],
  "Painted Protector"     => ["p20.png", 29, -28, 75, false],
  "Senshi the Undying"    => ["p21.png", 17, -6, 95, false],
  "Solus Hydraea"         => ["p22.png", 17, 65, 75, false],
  "The Mask Maker"        => ["p23.png", 3, -19, 80, false],
  "White Dove"            => ["p24.png", 6, -7, 100, true],
  "Zovena Vela"           => ["p25.png", 9, -19, 90, false],
  "Brighella"             => ["p26.png", 10, -15, 85, false],
  "Colombina"             => ["p27.png", 8, -2, 95, false],
  "Coviello"              => ["p28.png", 25, -9, 90, false],
  "The Demolitionist"     => "p29.png",
  "Escaped Madman"        => ["p30.png", -17, -19, 100, false],
  "Il Dottore"            => ["p31.png", 20, -20, 90, false],
  "Mezzetino"             => ["p32.png", 27, -12, 90, false],
  "Pantaleone"            => ["p33.png", -1, -9, 95, false],
  "Scapino"               => ["p34.png", 28, -2, 85, false],
  "Starspawn"             => ["p35.png", 8, -21, 85, false],
  "Pierrot"               => ["p36_a.png", 52, -20, 50, false],
}.each do |name, val|
  profile = Catalog::Profile.find_by(faction: "gifted", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Catalog::Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Pierrot" => "p36_b.png",
}.each do |name, val|
  profile = Catalog::Profile.find_by(faction: "gifted", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Catalog::Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

# ── Card References ────────────────────────────────────────────────────────────
profile_map = Catalog::Profile.where(faction: "gifted").each_with_object({}) { |p, h| h[p.name] = p.id }
now = Time.current
records = card_ref_data.map do |attrs|
  display_name = case attrs[:identifier]
                 when /-a$/ then "#{attrs[:name]} (A)"
                 when /-b$/ then "#{attrs[:name]} (B)"
                 else attrs[:name]
                 end
  { name: display_name, identifier: attrs[:identifier], profile_id: profile_map[attrs[:name]], created_at: now, updated_at: now }
end
Catalog::CardReference.upsert_all(records, unique_by: :identifier, update_only: %i[name profile_id])
cr_count = Catalog::CardReference.where(identifier: records.map { |r| r[:identifier] }).count
p_count  = Catalog::Profile.where(faction: "gifted").count
puts "Seeded Gifted: #{cr_count} card references, #{p_count} profiles."
