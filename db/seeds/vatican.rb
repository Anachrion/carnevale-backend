# ── Card References ────────────────────────────────────────────────────────────
card_ref_data = [
  { name: "Patriarch Bishop de Bernis",   identifier: "vatican-patriarch-bishop-de-bernis",   cost: 24 },
  { name: "Father Cesta",                 identifier: "vatican-father-cesta",                 cost: 24 },
  { name: "Exorcist",                     identifier: "vatican-exorcist",                     cost: 20 },
  { name: "Inquisitor",                   identifier: "vatican-inquisitor",                   cost: 22 },
  { name: "Knight Commander",             identifier: "vatican-knight-commander",             cost: 21 },
  { name: "Angel of the Blooded Rose",    identifier: "vatican-angel-of-the-blooded-rose",    cost: 20 },
  { name: "Felix Baumgartner",            identifier: "vatican-felix-baumgartner",            cost: 17 },
  { name: "Gethsemane",                   identifier: "vatican-gethsemane",                   cost: 37 },
  { name: "Eater of Sin",                 identifier: "vatican-eater-of-sin",                 cost: 16 },
  { name: "Avignon Guard",                identifier: "vatican-avignon-guard",                cost: 14 },
  { name: "Baptist",                      identifier: "vatican-baptist",                      cost: 15 },
  { name: "Burning Saint",                identifier: "vatican-burning-saint",                cost: 16 },
  { name: "Conventual Chaplain",          identifier: "vatican-conventual-chaplain",          cost: 13 },
  { name: "Cross-bearing Deacon",         identifier: "vatican-cross-bearing-deacon",         cost: 14 },
  { name: "Divine Seraphim",              identifier: "vatican-divine-seraphim",              cost: 18 },
  { name: "Executioner",                  identifier: "vatican-executioner",                  cost: 12 },
  { name: "Galilean Priest",              identifier: "vatican-galilean-priest",              cost: 17 },
  { name: "Golgotha",                     identifier: "vatican-golgotha",                     cost: 18 },
  { name: "Inquisition Commissioner",     identifier: "vatican-inquisition-commissioner",     cost: 16 },
  { name: "Knight of the Holy Sepulchre", identifier: "vatican-knight-of-the-holy-sepulchre", cost: 17 },
  { name: "Paladin of St Lazarus",        identifier: "vatican-paladin-of-st-lazarus",        cost: 16 },
  { name: "Prelate of the Flaming Sword", identifier: "vatican-prelate-of-the-flaming-sword", cost: 15 },
  { name: "Scorpio Marksman",             identifier: "vatican-scorpio-marksman",             cost: 15 },
  { name: "Sepulchral Vanguard",          identifier: "vatican-sepulchral-vanguard",          cost: 15 },
  { name: "Seraph",                       identifier: "vatican-seraph",                       cost: 17 },
  { name: "Silere Priest",                identifier: "vatican-silere-priest",                cost: 16 },
  { name: "Stigmatist",                   identifier: "vatican-stigmatist",                   cost: 13 },
  { name: "Summoner Priest",              identifier: "vatican-summoner-priest",              cost: 15 },
  { name: "Templar Marshal",              identifier: "vatican-templar-marshal",              cost: 14 },
  { name: "Throne",                       identifier: "vatican-throne",                       cost: 22 },
  { name: "Venator of Devotion",          identifier: "vatican-venator-of-devotion",          cost: 17 },
  { name: "French Infantryman",           identifier: "vatican-french-infantryman-a",         cost:  9 },
  { name: "French Infantryman",           identifier: "vatican-french-infantryman-b",         cost:  9 },
  { name: "Inquisitorial Spy",            identifier: "vatican-inquisitorial-spy",            cost:  9 },
  { name: "Knight of Malta",              identifier: "vatican-knight-of-malta-a",            cost: 14 },
  { name: "Knight of Malta",              identifier: "vatican-knight-of-malta-b",            cost: 14 },
  { name: "Lacrimosa",                    identifier: "vatican-lacrimosa",                    cost: 10 },
  { name: "Maltese Squire",               identifier: "vatican-maltese-squire-a",             cost: 10 },
  { name: "Maltese Squire",               identifier: "vatican-maltese-squire-b",             cost: 10 },
  { name: "Martyr",                       identifier: "vatican-martyr-a",                     cost:  8 },
  { name: "Martyr",                       identifier: "vatican-martyr-b",                     cost:  8 },
  { name: "Priest",                       identifier: "vatican-priest-a",                     cost: 10 },
  { name: "Priest",                       identifier: "vatican-priest-b",                     cost: 10 },
  { name: "Redemptionist",                identifier: "vatican-redemptionist-a",              cost: 12 },
  { name: "Redemptionist",                identifier: "vatican-redemptionist-b",              cost: 12 },
  { name: "Stalker",                      identifier: "vatican-stalker",                      cost: 12 },
  { name: "Thalassic Messenger",          identifier: "vatican-thalassic-messenger",          cost: 18 },
  { name: "Theophant of Sinai",           identifier: "vatican-theophant-of-sinai",           cost: 13 },
  { name: "Witch Finder",                 identifier: "vatican-witch-finder",                 cost: 12 },
  { name: "Thomas Thieme",                identifier: "vatican-thomas-thieme",                cost: 13 },
  { name: "Altar Boy",                    identifier: "vatican-altar-boy-a",                  cost:  8 },
  { name: "Altar Boy",                    identifier: "vatican-altar-boy-b",                  cost:  8 },
  { name: "Bishop Guard",                 identifier: "vatican-bishop-guard-a",               cost: 11 },
  { name: "Bishop Guard",                 identifier: "vatican-bishop-guard-b",               cost: 11 },
  { name: "Celestial Congregation",       identifier: "vatican-celestial-congregation",       cost: 15 },
  { name: "Celestial Spirit",             identifier: "vatican-celestial-spirit-a",           cost: 10 },
  { name: "Celestial Spirit",             identifier: "vatican-celestial-spirit-b",           cost: 10 },
  { name: "Cherubim",                     identifier: "vatican-cherubim-a",                   cost:  8 },
  { name: "Cherubim",                     identifier: "vatican-cherubim-b",                   cost:  8 },
  { name: "Chevaleresse",                 identifier: "vatican-chevaleresse-a",               cost: 11 },
  { name: "Chevaleresse",                 identifier: "vatican-chevaleresse-b",               cost: 11 },
  { name: "Crucifier",                    identifier: "vatican-crucifier",                    cost: 10 },
  { name: "Reliquary Page",               identifier: "vatican-reliquary-page",               cost:  9 },
]

now = Time.current
records = card_ref_data.map do |attrs|
  display_name = case attrs[:identifier]
                 when /-a$/ then "#{attrs[:name]} (A)"
                 when /-b$/ then "#{attrs[:name]} (B)"
                 else attrs[:name]
                 end
  { name: display_name, identifier: attrs[:identifier], created_at: now, updated_at: now }
end
CardReference.upsert_all(records, unique_by: :identifier, update_only: %i[name])

# ── The Vatican ────────────────────────────────────────────────────────────────

# Shared special rules
full_plate       = SpecialRule.find_or_create_by!(name: "Full Plate") { |r| r.description = "If this character ever enters water, it receives a Stunned counter which is only removed if it ends its turn out of water." }
stoneskin        = SpecialRule.find_or_create_by!(name: "Stoneskin") { |r| r.description = "Whenever this character takes damage, reduce the amount of damage caused by 3 (to a minimum of 1). In addition, if this character is hit by a Poisoned weapon, roll 2 dice and choose 1 to see if they shrug off the poison." }

# Leaders special rules
he_will_strengthen    = SpecialRule.find_or_create_by!(name: "He Will Strengthen You and Protect You") { |r| r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain Universal Shielding (3)." }
patriarch_bishop_rule = SpecialRule.find_or_create_by!(name: "Patriarch Bishop") { |r| r.description = "All friendly characters with the Faction (The Vatican) keyword gain Companion (Leader) while in line of sight of this character." }
gates_of_heaven       = SpecialRule.find_or_create_by!(name: "Gates of Heaven") { |r| r.description = "PULSE Command Ability. Until the end of the round, whenever a friendly character with the Construct keyword in line of sight within 6\" uses a Will Point to increase a roll, it instead counts as 2 Will Points." }
masterful_summoning   = SpecialRule.find_or_create_by!(name: "Masterful Summoning") { |r| r.description = "Friendly characters with the Construct keyword lose Mindless for the rest of the game, even if this character is killed." }
impart_will           = SpecialRule.find_or_create_by!(name: "Impart Will") { |r| r.description = "At the start of the game, all friendly characters with the Construct keyword increase their starting Will Points by 1." }
fear_the_lord         = SpecialRule.find_or_create_by!(name: "Fear the Lord") { |r| r.description = "PULSE Command Ability. Pick 1 enemy character within 6\". Until the end of the round, whenever that character is hit by a Combat action, the attacker gains Fear (-2)." }
helm_of_penitence     = SpecialRule.find_or_create_by!(name: "Helm of Penitence") { |r| r.description = "This character may attempt to Dispel magic spells as if it has Mage (3). In addition, enemy characters may not use Will Points when within 3\" of this character." }
exorcism              = SpecialRule.find_or_create_by!(name: "Exorcism") { |r| r.description = "When making a Combat action with Divine Touch, if it causes at least 1 Damage, the target loses 1 Will Point. If the target has 0 Will Points remaining, the attack instead does +3 Damage." }
for_the_glory         = SpecialRule.find_or_create_by!(name: "For the Glory of God") { |r| r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain Expert Offence (2)." }
stigmata              = SpecialRule.find_or_create_by!(name: "Stigmata") { |r| r.description = "If this character uses one or more Life Points as Will Points (due to Frenzied) either to increase the dice pool or to perform an action, it may re-roll an equal number of dice (including the Destiny Dice) during that action. If it does this on a Combat action, Hands of God instead has Penetration -3 for that action." }
fight_until_last      = SpecialRule.find_or_create_by!(name: "Fight Until the Last") { |r| r.description = "PULSE Command Ability. Used out of sequence at the start of the round before rolling initiative. Pick 1 friendly character in line of sight within 6\". If that character is reduced to 0 Life Points before they take their turn, they are not removed from the board — only removed after their turn is complete." }
destined_victory      = SpecialRule.find_or_create_by!(name: "Destined For Victory") { |r| r.description = "All friendly characters with the Hospitaller keyword may choose to re-roll the Destiny Dice when making re-rolls as long as this character is on the board." }

# Heroes special rules
born_of_blood       = SpecialRule.find_or_create_by!(name: "Born of Blood") { |r| r.description = "Whenever any character (friendly or enemy) is killed within 3\", this character replenishes 3 Life Points." }
heavenly_vision     = SpecialRule.find_or_create_by!(name: "Heavenly Vision") { |r| r.description = "Whenever a friendly character in line of sight within 6\" is instructed to replenish Will Points, increase the amount replenished by 1." }
put_through_heart   = SpecialRule.find_or_create_by!(name: "Put it Through the Heart!") { |r| r.description = "PULSE Command Ability. Pick a friendly character in line of sight within 12\". One of that character's weapons gains -4 Penetration until the end of the round." }
renewed_vigour      = SpecialRule.find_or_create_by!(name: "Renewed Vigour") { |r| r.description = "When this character kills an enemy character, he replenishes his full Will Points." }
feline_indifference = SpecialRule.find_or_create_by!(name: "Feline Indifference") { |r| r.description = "This character cannot be picked as a target for magic and is not affected by the effects of magic (other characters affected by magic are still affected)." }
serpentine          = SpecialRule.find_or_create_by!(name: "Serpentine") { |r| r.description = "This character is able to move through spaces smaller than its base to a minimum of 2\". It must be able to fit where it ends its turn." }
atonement_above     = SpecialRule.find_or_create_by!(name: "Atonement from Above") { |r| r.description = "Before applying Stoneskin, if this character would take damage from falling, all other characters (friendly and enemy) within 3\" also take that much damage. When this character charges from above, it may be placed on top of other characters, which are moved by their controlling player to be in base contact." }
let_sins_absolved   = SpecialRule.find_or_create_by!(name: "Let Your Sins Be Absolved") { |r| r.description = "When making a Combat action with Compelled Confession, if it causes at least 1 Damage, the target loses 1 Will Point." }
searches_soul       = SpecialRule.find_or_create_by!(name: "He Searches Your Soul Alone") { |r| r.description = "Enemy characters that can draw line of sight to this character cannot use the MIND value of other characters." }
communion_sinless   = SpecialRule.find_or_create_by!(name: "Communion for the Sinless") { |r| r.description = "When this character kills an enemy character that has 0 Will Points remaining (after absolving its sins), it replenishes 2 Will Points." }
blessed_water       = SpecialRule.find_or_create_by!(name: "Blessed Water - 1AP") { |r| r.description = "Place the Blast marker in water in line of sight within 8\". The area under the Blast marker is treated as solid ground for friendly characters. Enemy characters treat the area as water, and characters with the Water Creature rule can be drowned while at least partially on the marker. Remove the marker at the end of the round." }
walk_through_fire   = SpecialRule.find_or_create_by!(name: "Walk Through The Fire And You Will Not Be Burned") { |r| r.description = "1AP. The Saint summons holy flame around her! At the end of the round, place the Blast marker over this character. Any enemy character at least partially touched by this template (and within 1\" vertically of the Burning Saint) loses 3 Life Points. Characters may only be affected by this ability once per round, no matter how many times it's used by any number of Burning Saints! If the Burning Saint enters water after using this ability it is cancelled." }
psychic_communion   = SpecialRule.find_or_create_by!(name: "Psychic Communion") { |r| r.description = "Whenever this character or any other character with line of sight to this character uses the ORDER or COUNTER Commands, they ignore any other restrictions about line of sight." }
holy_relic          = SpecialRule.find_or_create_by!(name: "Holy Relic") { |r| r.description = "Any other friendly character (not including this one) that starts their turn within 6\" of this character replenishes 1 Will Point." }
righteous_zeal      = SpecialRule.find_or_create_by!(name: "Righteous Zeal") { |r| r.description = "Every friendly character gains Brave while in line of sight of this character." }
burn_fire_charity   = SpecialRule.find_or_create_by!(name: "Burn With The Fire of Charity") { |r| r.description = "While within 6\" of this character, friendly characters are immune to the Stun, Poisoned, and their own Full Plate abilities. At the end of each friendly character's turn, remove any Stun counters from friendly characters within 6\" of this character." }
bifurcation         = SpecialRule.find_or_create_by!(name: "Bifurcation") { |r| r.description = "When this character makes a Combat action (not an Attack of Opportunity) with the Executioner's Axe against a target character with a Size of 40mm or less and rolls at least 4 Aces, they are bifurcated! Instead of calculating Damage as normal, the target character loses half their remaining Life Points (rounding up)." }
water_affinity      = SpecialRule.find_or_create_by!(name: "Water Affinity") { |r| r.description = "This character always knows the magic spell Waves of Force in addition to its regular allowance, even if choosing to take spells from a different discipline. This character may use the Cast Spell action while in water." }
look_satisfaction   = SpecialRule.find_or_create_by!(name: "Look With Satisfaction Upon My Enemies") { |r| r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain Parry (2)." }
hasten_your_steps   = SpecialRule.find_or_create_by!(name: "Hasten Your Steps, The Unfaithful Must Be Cleansed") { |r| r.description = "PULSE Command Ability. All other friendly characters within 3\" gain +1 MOVEMENT until the end of the round." }
resurrection        = SpecialRule.find_or_create_by!(name: "Resurrection") { |r| r.description = "When this character is killed, do not remove it from the board. At the start of the next round, make a Basic MIND Roll (Will Points may be used as normal). If successful, this character comes back to life with 5 Life Points and gains Berserk for the rest of the game. If the MIND Roll is unsuccessful, the character is completely dead and removed from the board." }
burning_aura        = SpecialRule.find_or_create_by!(name: "Burning Aura") { |r| r.description = "Any friendly characters without this ability within 3\" gain -2 Penetration on their weapons." }
unwieldy            = SpecialRule.find_or_create_by!(name: "Unwieldy") { |r| r.description = "This character may only make Combat actions with the Scorpio as the first action of their turn (including using it for Attacks of Opportunity)." }
guard_against_witch = SpecialRule.find_or_create_by!(name: "I will guard against thee, Witch") { |r| r.description = "This character may attempt to Dispel magic spells as if it has Mage (1). In addition, enemy characters may not use Will Points when in base contact with this character." }
holy_grace          = SpecialRule.find_or_create_by!(name: "Holy Grace") { |r| r.description = "Whenever this character makes a successful Combat action (before Protection rolls), the target loses 1 Will Point and this character gains 1 Will Point. This can take this character above its starting Will Points." }
keeper_of_fire      = SpecialRule.find_or_create_by!(name: "Keeper of the Fire of the Persecution") { |r| r.description = "Any friendly characters without this ability within 3\" gain +1 Damage on their weapons." }
come_let_us_make    = SpecialRule.find_or_create_by!(name: "Come Let Us Make Bricks and Burn Them Thoroughly") { |r| r.description = "PULSE Command Ability. Remove 1 friendly character with the Construct keyword from the board. Place it within 3\" of this character (with no changes to its Life Points)." }
be_thou_afraid      = SpecialRule.find_or_create_by!(name: "Be Thou Afraid?") { |r| r.description = "If an enemy character would roll no Aces on its basic MIND roll due to this character's Fear ability, that character loses 1 Will Point." }
cosmic_harmony      = SpecialRule.find_or_create_by!(name: "Cosmic Harmony") { |r| r.description = "At the start of this character's turn, choose a friendly character within 6\" and in line of sight. This character and the chosen character both replenish 1 Command Point." }
killing_blow        = SpecialRule.find_or_create_by!(name: "Killing Blow") { |r| r.description = "If this character causes an enemy character to lose more Life Points than they have left (ie. they'd go to minus numbers), this character replenishes all of its Will Points." }
vampire_hunter      = SpecialRule.find_or_create_by!(name: "Vampire Hunter") { |r| r.description = "When making a Combat action against a character with 0 Will Points remaining, Thomas may re-roll all dice, including the Destiny Dice." }
spurring_incense    = SpecialRule.find_or_create_by!(name: "Spurring Incense - 1AP") { |r| r.description = "Until the end of the round, any friendly character that starts its action within 6\" and line of sight of this character gains First Strike (2) for that action and any subsequent Attacks of Opportunity." }
censer_bearer       = SpecialRule.find_or_create_by!(name: "Censer Bearer") { |r| r.description = "Any friendly character that starts its turn within 6\" and in line of sight of this character replenishes 1 Will Point. Characters with the Censer Bearer rule cannot be affected by this rule. Characters cannot be affected by multiple instances of this rule in one turn." }
ensoul              = SpecialRule.find_or_create_by!(name: "Ensoul - 3LP") { |r| r.description = "One other friendly character with the Construct keyword without this ability replenishes 3 Life Points. This ability can only be used once per turn, but can be used even if it would kill this character. If this character uses its last Life Points on this ability, the target replenishes 5 Life Points instead." }
enspirit            = SpecialRule.find_or_create_by!(name: "Enspirit - 4LP") { |r| r.description = "This character may use the ORDER command on friendly characters with the Construct keyword, consuming 4 Life Points instead of 1 Command Point. This can be used even if it would kill this character. If this character uses its last Life Points on this ability, the target replenishes 1 Will Point." }
living_proof        = SpecialRule.find_or_create_by!(name: "Living Proof of God's Majesty") { |r| r.description = "Friendly characters with the Companion ability also have Companion (Cherubim)." }
crucifixion_rule    = SpecialRule.find_or_create_by!(name: "Crucifixion") { |r| r.description = "When this character makes a Combat action with the Hammer & Nails and rolls at least 3 Aces, change its Penetration to -4." }

# Henchmen special rules
illicit_information = SpecialRule.find_or_create_by!(name: "Illicit Information") { |r| r.description = "For every friendly character with this ability in your gang at the start of the round, add a re-roll to your Illicit Information Pool. Until the end of the round, any friendly character may use these re-rolls on any roll - one re-roll per dice." }
candid_soul         = SpecialRule.find_or_create_by!(name: "Candid Soul") { |r| r.description = "For every Life Point this character uses as a Will Point due to Frenzied, all other friendly characters without this rule within 3\" replenish 1 Life Point." }
living_tide         = SpecialRule.find_or_create_by!(name: "Living Tide") { |r| r.description = "This character can re-roll any failed dice rolls when making Drown and Dive actions." }
living_flame        = SpecialRule.find_or_create_by!(name: "Living Flame") { |r| r.description = "This character loses double Life Points from Drown actions." }
infernal_ally       = SpecialRule.find_or_create_by!(name: "Infernal Ally") { |r| r.description = "While this character is on solid ground, enemy characters that end their turn in base contact with this character lose 1 Life Point." }
suffer_not_witch    = SpecialRule.find_or_create_by!(name: "Suffer Not a Witch") { |r| r.description = "This character may attempt to Dispel magic spells as if it has Mage (2). In addition, enemy characters may not use Will Points when in base contact with this character." }
pursuit             = SpecialRule.find_or_create_by!(name: "Pursuit") { |r| r.description = "When using a COUNTER Command on this character, it does not cost a Command Point (although still counts as a use of the Command for all other purposes)." }
relics_of_malta     = SpecialRule.find_or_create_by!(name: "Relics of Malta") { |r| r.description = "Once per each of their turns, any friendly character within 6\" and line of sight of a friendly character with this rule may re-roll 1 single dice on any roll they make. This character is affected by its own Relics of Malta rule." }

# Weapons
unarmed_vat        = Weapon.find_or_create_by!(name: "Unarmed") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 1; w.abilities = [] }
crosier            = Weapon.find_or_create_by!(name: "Crosier") { |w| w.range = 2; w.evasion = 0; w.damage = 0; w.penetration = 0; w.abilities = [] }
divine_winds       = Weapon.find_or_create_by!(name: "Divine Winds") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Template"] }
divine_touch       = Weapon.find_or_create_by!(name: "Divine Touch") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 0; w.abilities = ["Stun"] }
hands_of_god       = Weapon.find_or_create_by!(name: "Hands of God") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = 1; w.abilities = [] }
blade_of_gozo      = Weapon.find_or_create_by!(name: "Blade of Gozo") { |w| w.range = 0; w.evasion = 0; w.damage = 2; w.penetration = -1; w.abilities = [] }
ahlspiess          = Weapon.find_or_create_by!(name: "Ahlspiess") { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Two-handed"] }
holy_instruments   = Weapon.find_or_create_by!(name: "Holy Instruments") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = [] }
agonising_strike   = Weapon.find_or_create_by!(name: "Agonising Strike") { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Knockback"] }
claw_of_anguish    = Weapon.find_or_create_by!(name: "Claw of Anguish") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = -1; w.abilities = ["Reload (2)", "Template"] }
maw_press          = Weapon.find_or_create_by!(name: "Maw Press") { |w| w.range = 0; w.evasion = -1; w.damage = 0; w.penetration = -4; w.abilities = [] }
compelled_confession = Weapon.find_or_create_by!(name: "Compelled Confession") { |w| w.range = 0; w.evasion = -2; w.damage = 0; w.penetration = 0; w.abilities = ["Stun"] }
greatsword         = Weapon.find_or_create_by!(name: "Greatsword") { |w| w.range = 1; w.evasion = 0; w.damage = 2; w.penetration = 0; w.abilities = ["Two-handed"] }
blessed_sword      = Weapon.find_or_create_by!(name: "Blessed Sword") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = -1; w.abilities = [] }
sword_vat          = Weapon.find_or_create_by!(name: "Sword") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = [] }
holy_icon          = Weapon.find_or_create_by!(name: "Holy Icon") { |w| w.range = 2; w.evasion = 0; w.damage = 0; w.penetration = 0; w.abilities = ["Two-handed"] }
divine_flame       = Weapon.find_or_create_by!(name: "Divine Flame") { |w| w.range = 0; w.evasion = -2; w.damage = 0; w.penetration = -2; w.abilities = ["Template"] }
executioners_axe   = Weapon.find_or_create_by!(name: "Executioner's Axe") { |w| w.range = 0; w.evasion = 1; w.damage = 1; w.penetration = 0; w.abilities = [] }
stone_fists        = Weapon.find_or_create_by!(name: "Stone Fists") { |w| w.range = 0; w.evasion = 1; w.damage = 2; w.penetration = 0; w.abilities = [] }
pistol_vat         = Weapon.find_or_create_by!(name: "Pistol") { |w| w.range = 8; w.evasion = 1; w.damage = 0; w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
flail              = Weapon.find_or_create_by!(name: "Flail") { |w| w.range = 2; w.evasion = 1; w.damage = 2; w.penetration = 0; w.abilities = [] }
warhammer          = Weapon.find_or_create_by!(name: "Warhammer") { |w| w.range = 1; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Stun", "Two-handed"] }
burning_longsword  = Weapon.find_or_create_by!(name: "Burning Longsword") { |w| w.range = 1; w.evasion = 0; w.damage = 1; w.penetration = -5; w.abilities = ["Two-handed"] }
scorpio_weapon     = Weapon.find_or_create_by!(name: "Scorpio") { |w| w.range = 18; w.evasion = 1; w.damage = 2; w.penetration = -2; w.abilities = ["Knockback", "Two-handed", "Reload (1)"] }
flaming_mace       = Weapon.find_or_create_by!(name: "Flaming Mace") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = -2; w.abilities = ["Stun"] }
angelic_touch      = Weapon.find_or_create_by!(name: "Angelic Touch") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = [] }
fire_of_persecution = Weapon.find_or_create_by!(name: "Fire of Persecution") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = -1; w.abilities = [] }
divine_justice_w   = Weapon.find_or_create_by!(name: "Divine Justice") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Knockback", "Stun"] }
zweihander         = Weapon.find_or_create_by!(name: "Zweihänder") { |w| w.range = 2; w.evasion = 1; w.damage = 3; w.penetration = 0; w.abilities = ["Knockback", "Two-handed"] }
hammer_and_stake   = Weapon.find_or_create_by!(name: "Hammer & Stake") { |w| w.range = 0; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Two-handed"] }
heavenly_clamour   = Weapon.find_or_create_by!(name: "Heavenly Clamour") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -3; w.abilities = [] }
heavenly_grasp     = Weapon.find_or_create_by!(name: "Heavenly Grasp") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = [] }
feathers_holy_light = Weapon.find_or_create_by!(name: "Feathers of Holy Light") { |w| w.range = 6; w.evasion = -1; w.damage = 0; w.penetration = -1; w.abilities = [] }
crossbow_vat       = Weapon.find_or_create_by!(name: "Crossbow") { |w| w.range = 30; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = ["Reload (1)", "Two-handed"] }
hammer_and_nails   = Weapon.find_or_create_by!(name: "Hammer & Nails") { |w| w.range = 0; w.evasion = 0; w.damage = 0; w.penetration = -2; w.abilities = ["Two-handed"] }
halberd_swing      = Weapon.find_or_create_by!(name: "Halberd (swing)") { |w| w.range = 2; w.evasion = 0; w.damage = 1; w.penetration = 0; w.abilities = ["Two-handed"] }
halberd_thrust     = Weapon.find_or_create_by!(name: "Halberd (thrust)") { |w| w.range = 2; w.evasion = 0; w.damage = 0; w.penetration = -2; w.abilities = [] }
corseque           = Weapon.find_or_create_by!(name: "Corseque")          { |w| w.range = 2;  w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = ["Knockback", "Two-handed"] }
sharpened_dagger   = Weapon.find_or_create_by!(name: "Sharpened Dagger")  { |w| w.range = 0;  w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = [] }
tools_of_penance   = Weapon.find_or_create_by!(name: "Tools of Penance")  { |w| w.range = 0;  w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = [] }
club               = Weapon.find_or_create_by!(name: "Club")              { |w| w.range = 0;  w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = ["Stun"] }
short_sword        = Weapon.find_or_create_by!(name: "Short Sword")       { |w| w.range = 0;  w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = [] }
handbow            = Weapon.find_or_create_by!(name: "Handbow")           { |w| w.range = 15; w.evasion = 0; w.damage = 0; w.penetration = -1; w.abilities = ["Reload (2)"] }
hellfire           = Weapon.find_or_create_by!(name: "Hellfire")          { |w| w.range = 8;  w.evasion = 0; w.damage = 3; w.penetration = -2; w.abilities = ["Black Powder", "Reload (1)"] }
snare              = Weapon.find_or_create_by!(name: "Snare")             { |w| w.range = 2;  w.evasion = 0; w.damage = 0; w.penetration =  0; w.abilities = ["Two-handed"] }

# Leaders
patriarch_bishop_de_bernis = Profile.find_or_create_by!(name: "Patriarch Bishop de Bernis") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 12; p.will_points = 8; p.command_points = 3
  p.size = 30; p.ducats = 24; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 5
  p.keywords = ["Leader", "Unique", "Discipline (Divinity, Fateweaving, Wild Magic)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (3)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: patriarch_bishop_de_bernis, weapon: crosier) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: patriarch_bishop_de_bernis, special_rule: he_will_strengthen) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: patriarch_bishop_de_bernis, special_rule: patriarch_bishop_rule) { |psr| psr.position = 1 }

father_cesta = Profile.find_or_create_by!(name: "Father Cesta") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 12; p.will_points = 4; p.command_points = 3
  p.size = 40; p.ducats = 24; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Leader", "Invoker", "Unique", "Discipline (Runes of Sovereignty, Wild Magic)"]
  p.abilities = ["Flight", "Mage (2)", "Slippery", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: father_cesta, weapon: divine_winds) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: father_cesta, special_rule: gates_of_heaven) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: father_cesta, special_rule: masterful_summoning) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: father_cesta, special_rule: impart_will) { |psr| psr.position = 2 }

exorcist = Profile.find_or_create_by!(name: "Exorcist") do |p|
  p.version = "2.3.1"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 13; p.will_points = 4; p.command_points = 3
  p.size = 30; p.ducats = 20; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 6
  p.keywords = ["Leader"]
  p.abilities = ["Fear (-2)"]
end
ProfileWeapon.find_or_create_by!(profile: exorcist, weapon: divine_touch) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: exorcist, special_rule: fear_the_lord) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: exorcist, special_rule: helm_of_penitence) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: exorcist, special_rule: exorcism) { |psr| psr.position = 2 }

inquisitor = Profile.find_or_create_by!(name: "Inquisitor") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 13; p.will_points = 2; p.command_points = 4
  p.size = 30; p.ducats = 22; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["Leader", "Discipline (Blood Rites, Runes of Sovereignty, Wild Magic)"]
  p.abilities = ["Frenzied", "Mage (3)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: inquisitor, weapon: hands_of_god) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: inquisitor, special_rule: for_the_glory) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: inquisitor, special_rule: stigmata) { |psr| psr.position = 1 }

knight_commander = Profile.find_or_create_by!(name: "Knight Commander") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 14; p.will_points = 3; p.command_points = 3
  p.size = 30; p.ducats = 21; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 5
  p.keywords = ["Leader", "Hospitaller"]
  p.abilities = ["Brave", "Expert Offence (2)", "Hunter", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: knight_commander, weapon: blade_of_gozo) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: knight_commander, special_rule: fight_until_last) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: knight_commander, special_rule: destined_victory) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: knight_commander, special_rule: full_plate) { |psr| psr.position = 2 }

# Heroes
angel_blooded_rose = Profile.find_or_create_by!(name: "Angel of the Blooded Rose") do |p|
  p.version = "2.2.1"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 20; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["Hero", "Unique", "Hospitaller"]
  p.abilities = ["Flight", "Frenzied", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: angel_blooded_rose, weapon: ahlspiess) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: angel_blooded_rose, special_rule: born_of_blood) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: angel_blooded_rose, special_rule: heavenly_vision) { |psr| psr.position = 1 }

felix_baumgartner = Profile.find_or_create_by!(name: "Felix Baumgartner") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 4; p.command_points = 2
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Brawler (1)", "Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: felix_baumgartner, weapon: holy_instruments) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: felix_baumgartner, special_rule: put_through_heart) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: felix_baumgartner, special_rule: renewed_vigour) { |psr| psr.position = 1 }

gethsemane = Profile.find_or_create_by!(name: "Gethsemane") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 3; p.life_points = 28; p.will_points = 0; p.command_points = 0
  p.size = 75; p.ducats = 37; p.movement = 4; p.dexterity = 4; p.attack = 5; p.protection = 0; p.mind = 1
  p.keywords = ["Hero", "Unique", "Construct"]
  p.abilities = ["Acrobatic (2)", "Brave", "Brawler (1)", "Bulky", "Companion (Invoker)", "Frenzied", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: gethsemane, weapon: agonising_strike) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: gethsemane, weapon: claw_of_anguish) { |pw| pw.position = 1 }
ProfileWeapon.find_or_create_by!(profile: gethsemane, weapon: maw_press) { |pw| pw.position = 2 }
ProfileSpecialRule.find_or_create_by!(profile: gethsemane, special_rule: stoneskin) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: gethsemane, special_rule: feline_indifference) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: gethsemane, special_rule: serpentine) { |psr| psr.position = 2 }
ProfileSpecialRule.find_or_create_by!(profile: gethsemane, special_rule: atonement_above) { |psr| psr.position = 3 }

eater_of_sin = Profile.find_or_create_by!(name: "Eater of Sin") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Unique"]
  p.abilities = ["Brave", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: eater_of_sin, weapon: compelled_confession) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: eater_of_sin, special_rule: let_sins_absolved) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: eater_of_sin, special_rule: searches_soul) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: eater_of_sin, special_rule: communion_sinless) { |psr| psr.position = 2 }

avignon_guard = Profile.find_or_create_by!(name: "Avignon Guard") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 14; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = ["Brawler (1)", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: avignon_guard, weapon: greatsword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: avignon_guard, special_rule: full_plate) { |psr| psr.position = 0 }

baptist = Profile.find_or_create_by!(name: "Baptist") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 5
  p.keywords = ["Hero", "Discipline (Divinity)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: baptist, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: baptist, special_rule: blessed_water) { |psr| psr.position = 0 }

burning_saint = Profile.find_or_create_by!(name: "Burning Saint") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 0
  p.size = 40; p.ducats = 16; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 4
  p.keywords = ["Hero", "Hospitaller"]
  p.abilities = ["Brave", "Expert Offence (2)", "Universal Shielding (6)"]
end
ProfileWeapon.find_or_create_by!(profile: burning_saint, weapon: blessed_sword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: burning_saint, special_rule: walk_through_fire) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: burning_saint, special_rule: full_plate) { |psr| psr.position = 1 }

conventual_chaplain = Profile.find_or_create_by!(name: "Conventual Chaplain") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 4
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Hospitaller"]
  p.abilities = []
end
ProfileWeapon.find_or_create_by!(profile: conventual_chaplain, weapon: sword_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: conventual_chaplain, special_rule: psychic_communion) { |psr| psr.position = 0 }

cross_bearing_deacon = Profile.find_or_create_by!(name: "Cross-bearing Deacon") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 5
  p.keywords = ["Hero"]
  p.abilities = ["Brave", "Universal Shielding (5)"]
end
ProfileWeapon.find_or_create_by!(profile: cross_bearing_deacon, weapon: holy_icon) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cross_bearing_deacon, special_rule: holy_relic) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cross_bearing_deacon, special_rule: righteous_zeal) { |psr| psr.position = 1 }

divine_seraphim = Profile.find_or_create_by!(name: "Divine Seraphim") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 18; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 1
  p.keywords = ["Hero", "Construct"]
  p.abilities = ["Companion (Invoker)", "Fear (-1)", "Flight", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: divine_seraphim, weapon: divine_flame) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: divine_seraphim, special_rule: burn_fire_charity) { |psr| psr.position = 0 }

executioner = Profile.find_or_create_by!(name: "Executioner") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 1; p.mind = 2
  p.keywords = ["Hero"]
  p.abilities = ["Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: executioner, weapon: executioners_axe) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: executioner, special_rule: bifurcation) { |psr| psr.position = 0 }

galilean_priest = Profile.find_or_create_by!(name: "Galilean Priest") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 6; p.command_points = 2
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Invoker", "Discipline (Fateweaving, Wild Magic)"]
  p.abilities = ["Fast Swimmer (2)", "Mage (2)", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: galilean_priest, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: galilean_priest, special_rule: water_affinity) { |psr| psr.position = 0 }

golgotha = Profile.find_or_create_by!(name: "Golgotha") do |p|
  p.version = "2.3.1"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 20; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 18; p.movement = 4; p.dexterity = 3; p.attack = 6; p.protection = 0; p.mind = 1
  p.keywords = ["Hero", "Construct"]
  p.abilities = ["Bulky", "Companion (Invoker)", "Fear (0)", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: golgotha, weapon: stone_fists) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: golgotha, special_rule: stoneskin) { |psr| psr.position = 0 }

inquisition_commissioner = Profile.find_or_create_by!(name: "Inquisition Commissioner") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 3
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Hero"]
  p.abilities = ["Expert Marksman (2)", "Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: inquisition_commissioner, weapon: pistol_vat) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: inquisition_commissioner, weapon: sword_vat) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: inquisition_commissioner, special_rule: look_satisfaction) { |psr| psr.position = 0 }

knight_holy_sepulchre = Profile.find_or_create_by!(name: "Knight of the Holy Sepulchre") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 18; p.will_points = 0; p.command_points = 2
  p.size = 50; p.ducats = 17; p.movement = 6; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 1
  p.keywords = ["Hero"]
  p.abilities = ["Brawler (1)", "Frenzied", "Limited Movement", "Mindless", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: knight_holy_sepulchre, weapon: flail) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: knight_holy_sepulchre, special_rule: hasten_your_steps) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: knight_holy_sepulchre, special_rule: full_plate) { |psr| psr.position = 1 }

paladin_st_lazarus = Profile.find_or_create_by!(name: "Paladin of St Lazarus") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 14; p.will_points = 2; p.command_points = 1
  p.size = 40; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 2
  p.keywords = ["Hero", "Hospitaller"]
  p.abilities = ["Expert Offence (1)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: paladin_st_lazarus, weapon: warhammer) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: paladin_st_lazarus, special_rule: resurrection) { |psr| psr.position = 0 }

prelate_flaming_sword = Profile.find_or_create_by!(name: "Prelate of the Flaming Sword") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 2
  p.keywords = ["Hero"]
  p.abilities = ["Brave", "Bulky", "Expert Offence (2)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: prelate_flaming_sword, weapon: burning_longsword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: prelate_flaming_sword, special_rule: burning_aura) { |psr| psr.position = 0 }

scorpio_marksman = Profile.find_or_create_by!(name: "Scorpio Marksman") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 0
  p.size = 50; p.ducats = 15; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 5; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = ["Expert Marksman (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: scorpio_marksman, weapon: scorpio_weapon) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: scorpio_marksman, special_rule: unwieldy) { |psr| psr.position = 0 }

sepulchral_vanguard = Profile.find_or_create_by!(name: "Sepulchral Vanguard") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 15; p.movement = 5; p.dexterity = 3; p.attack = 3; p.protection = 5; p.mind = 3
  p.keywords = ["Hero"]
  p.abilities = ["Bodyguard (Leader, Hero)", "Expert Protection (3)", "Frenzied", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: sepulchral_vanguard, weapon: flaming_mace) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: sepulchral_vanguard, special_rule: guard_against_witch) { |psr| psr.position = 0 }

seraph_profile = Profile.find_or_create_by!(name: "Seraph") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 15; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 17; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 6; p.mind = 1
  p.keywords = ["Hero", "Construct"]
  p.abilities = ["Companion (Invoker)", "Fear (0)", "Flight", "Mindless", "Primitive"]
end
ProfileWeapon.find_or_create_by!(profile: seraph_profile, weapon: angelic_touch) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: seraph_profile, special_rule: holy_grace) { |psr| psr.position = 0 }

silere_priest = Profile.find_or_create_by!(name: "Silere Priest") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Hero", "Discipline (Fateweaving, Runes of Sovereignty)"]
  p.abilities = ["Mage (1)", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: silere_priest, weapon: fire_of_persecution) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: silere_priest, special_rule: keeper_of_fire) { |psr| psr.position = 0 }

stigmatist_profile = Profile.find_or_create_by!(name: "Stigmatist") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["Hero", "Discipline (Blood Rites)"]
  p.abilities = ["Frenzied", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: stigmatist_profile, weapon: hands_of_god) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: stigmatist_profile, special_rule: stigmata) { |psr| psr.position = 0 }

summoner_priest = Profile.find_or_create_by!(name: "Summoner Priest") do |p|
  p.version = "2.3.1"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 2
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["Hero", "Invoker", "Discipline (Fateweaving, Runes of Sovereignty)"]
  p.abilities = ["Mage (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: summoner_priest, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: summoner_priest, special_rule: come_let_us_make) { |psr| psr.position = 0 }

templar_marshal = Profile.find_or_create_by!(name: "Templar Marshal") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["Hero", "Hospitaller"]
  p.abilities = ["Engage", "Expert Marksman (1)", "Expert Offence (1)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: templar_marshal, weapon: crossbow_vat) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: templar_marshal, weapon: sword_vat) { |pw| pw.position = 1 }

throne_profile = Profile.find_or_create_by!(name: "Throne") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 16; p.will_points = 0; p.command_points = 1
  p.size = 50; p.ducats = 22; p.movement = 6; p.dexterity = 3; p.attack = 4; p.protection = 4; p.mind = 1
  p.keywords = ["Hero", "Construct"]
  p.abilities = ["Companion (Invoker)", "Fear (-2)", "Flight", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: throne_profile, weapon: divine_justice_w) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: throne_profile, special_rule: be_thou_afraid) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: throne_profile, special_rule: cosmic_harmony) { |psr| psr.position = 1 }

venator_of_devotion = Profile.find_or_create_by!(name: "Venator of Devotion") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 14; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 17; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 6; p.mind = 4
  p.keywords = ["Hero", "Hospitaller"]
  p.abilities = ["Expert Offence (1)", "Hunter", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: venator_of_devotion, weapon: zweihander) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: venator_of_devotion, weapon: sword_vat) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: venator_of_devotion, special_rule: killing_blow) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: venator_of_devotion, special_rule: full_plate) { |psr| psr.position = 1 }

# Henchmen
thomas_thieme = Profile.find_or_create_by!(name: "Thomas Thieme") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman", "Unique"]
  p.abilities = ["Brave", "Bodyguard (Felix Baumgartner)", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: thomas_thieme, weapon: hammer_and_stake) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: thomas_thieme, special_rule: vampire_hunter) { |psr| psr.position = 0 }

altar_boy = Profile.find_or_create_by!(name: "Altar Boy") do |p|
  p.version = "2.4.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 8; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 5; p.attack = 2; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Concealment (+2)"]
end
ProfileWeapon.find_or_create_by!(profile: altar_boy, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: altar_boy, special_rule: spurring_incense) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: altar_boy, special_rule: censer_bearer) { |psr| psr.position = 1 }

bishop_guard = Profile.find_or_create_by!(name: "Bishop Guard") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Bodyguard (Leader)", "Expert Protection (1)"]
end
ProfileWeapon.find_or_create_by!(profile: bishop_guard, weapon: halberd_swing) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: bishop_guard, weapon: halberd_thrust) { |pw| pw.position = 1 }

celestial_congregation = Profile.find_or_create_by!(name: "Celestial Congregation") do |p|
  p.version = "2.3.1"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 15; p.will_points = 1; p.command_points = 0
  p.size = 50; p.ducats = 15; p.movement = 4; p.dexterity = 3; p.attack = 4; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Construct"]
  p.abilities = ["Companion (Invoker)", "Ethereal", "Fear (-1)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: celestial_congregation, weapon: heavenly_clamour) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: celestial_congregation, special_rule: ensoul) { |psr| psr.position = 0 }

celestial_spirit = Profile.find_or_create_by!(name: "Celestial Spirit") do |p|
  p.version = "2.3.1"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 8; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Construct"]
  p.abilities = ["Companion (Invoker)", "Ethereal", "Fear (0)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: celestial_spirit, weapon: heavenly_grasp) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: celestial_spirit, special_rule: enspirit) { |psr| psr.position = 0 }

cherubim_profile = Profile.find_or_create_by!(name: "Cherubim") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 8; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 2; p.mind = 2
  p.keywords = ["Henchman", "Construct"]
  p.abilities = ["Fear (-1)", "Mindless", "Limited Movement", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: cherubim_profile, weapon: feathers_holy_light) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: cherubim_profile, special_rule: living_proof) { |psr| psr.position = 0 }

chevaleresse = Profile.find_or_create_by!(name: "Chevaleresse") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["Henchman", "Hospitaller"]
  p.abilities = ["Bodyguard (Henchman)", "Parry (1)"]
end
ProfileWeapon.find_or_create_by!(profile: chevaleresse, weapon: sword_vat) { |pw| pw.position = 0 }

crucifier_profile = Profile.find_or_create_by!(name: "Crucifier") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Companion (Leader)"]
end
ProfileWeapon.find_or_create_by!(profile: crucifier_profile, weapon: hammer_and_nails) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: crucifier_profile, special_rule: crucifixion_rule) { |psr| psr.position = 0 }

french_infantryman = Profile.find_or_create_by!(name: "French Infantryman") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: french_infantryman, weapon: corseque) { |pw| pw.position = 0 }

inquisitorial_spy = Profile.find_or_create_by!(name: "Inquisitorial Spy") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Henchman"]
  p.abilities = ["Infiltration", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: inquisitorial_spy, weapon: sharpened_dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: inquisitorial_spy, special_rule: illicit_information) { |psr| psr.position = 0 }

knight_of_malta = Profile.find_or_create_by!(name: "Knight of Malta") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["Henchman", "Hospitaller"]
  p.abilities = ["Brave", "Companion (Hospitaller)", "Expert Protection (2)"]
end
ProfileWeapon.find_or_create_by!(profile: knight_of_malta, weapon: sword_vat) { |pw| pw.position = 0 }

lacrimosa = Profile.find_or_create_by!(name: "Lacrimosa") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["Henchman", "Discipline (Divinity)"]
  p.abilities = ["Frenzied", "Mage (2)", "Universal Shielding (3)"]
end
ProfileWeapon.find_or_create_by!(profile: lacrimosa, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: lacrimosa, special_rule: candid_soul) { |psr| psr.position = 0 }

maltese_squire = Profile.find_or_create_by!(name: "Maltese Squire") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman", "Hospitaller"]
  p.abilities = ["Companion (Leader)"]
end
ProfileWeapon.find_or_create_by!(profile: maltese_squire, weapon: crossbow_vat) { |pw| pw.position = 0 }

martyr = Profile.find_or_create_by!(name: "Martyr") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman"]
  p.abilities = ["Frenzied", "Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: martyr, weapon: tools_of_penance) { |pw| pw.position = 0 }

priest_profile = Profile.find_or_create_by!(name: "Priest") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Expert Offence (1)"]
end
ProfileWeapon.find_or_create_by!(profile: priest_profile, weapon: club) { |pw| pw.position = 0 }

redemptionist = Profile.find_or_create_by!(name: "Redemptionist") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["First Strike (1)", "Frenzied"]
end
ProfileWeapon.find_or_create_by!(profile: redemptionist, weapon: short_sword) { |pw| pw.position = 0 }

stalker_profile = Profile.find_or_create_by!(name: "Stalker") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["Henchman"]
  p.abilities = ["Concealment (+1)", "Infiltration"]
end
ProfileWeapon.find_or_create_by!(profile: stalker_profile, weapon: handbow) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: stalker_profile, special_rule: pursuit) { |psr| psr.position = 0 }

thalassic_messenger = Profile.find_or_create_by!(name: "Thalassic Messenger") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 12; p.will_points = 0; p.command_points = 0
  p.size = 50; p.ducats = 18; p.movement = 3; p.dexterity = 4; p.attack = 4; p.protection = 5; p.mind = 1
  p.keywords = ["Henchman", "Construct"]
  p.abilities = ["Companion (Invoker)", "Fast Swimmer (3)", "Primitive", "Universal Shielding (4)", "Water Creature"]
end
ProfileWeapon.find_or_create_by!(profile: thalassic_messenger, weapon: angelic_touch) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: thalassic_messenger, special_rule: living_tide) { |psr| psr.position = 0 }

theophant_of_sinai = Profile.find_or_create_by!(name: "Theophant of Sinai") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 13; p.will_points = 0; p.command_points = 0
  p.size = 40; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["Henchman", "Construct"]
  p.abilities = ["Companion (Invoker)", "Mindless", "Primitive", "Universal Shielding (2)"]
end
ProfileWeapon.find_or_create_by!(profile: theophant_of_sinai, weapon: hellfire) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: theophant_of_sinai, special_rule: living_flame) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: theophant_of_sinai, special_rule: infernal_ally) { |psr| psr.position = 1 }

witch_finder = Profile.find_or_create_by!(name: "Witch Finder") do |p|
  p.version = "2.2.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 9; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 4
  p.keywords = ["Henchman"]
  p.abilities = ["Engage", "Expert Grappler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: witch_finder, weapon: snare) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: witch_finder, special_rule: suffer_not_witch) { |psr| psr.position = 0 }

reliquary_page = Profile.find_or_create_by!(name: "Reliquary Page") do |p|
  p.version = "2.3.0"; p.faction = "vatican"
  p.action_points = 2; p.life_points = 8; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 5; p.attack = 2; p.protection = 3; p.mind = 2
  p.keywords = ["Henchman"]
  p.abilities = ["Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: reliquary_page, weapon: unarmed_vat) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: reliquary_page, special_rule: relics_of_malta) { |psr| psr.position = 0 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Pages 34, 46, 48 produced _a variants. Pages 33, 35-45, 47 are non-profile pages.
{
  "Patriarch Bishop de Bernis" => ["p02.png", 5, -3, 85, false],
  "Father Cesta"               => ["p03.png", -20, -18, 100, false],
  "Exorcist"                   => ["p04.png", -4, -13, 95, false],
  "Inquisitor"                 => ["p05.png", -8, -14, 95, false],
  "Knight Commander"           => ["p06.png", -5, -7, 100, false],
  "Angel of the Blooded Rose"  => ["p07.png", 17, -6, 90, false],
  "Felix Baumgartner"          => ["p08.png", 6, -18, 90, false],
  "Gethsemane"                 => ["p09.png", -17, 20, 115, false],
  "Eater of Sin"               => ["p10.png", 22, -18, 85, false],
  "Avignon Guard"              => ["p11.png", -10, -21, 85, false],
  "Baptist"                    => ["p12.png", -3, -10, 95, false],
  "Burning Saint"              => ["p13.png", 11, -11, 90, false],
  "Conventual Chaplain"        => ["p14.png", -4, -20, 95, false],
  "Cross-bearing Deacon"       => ["p15.png", -20, 41, 105, false],
  "Divine Seraphim"            => ["p16.png", 31, 4, 80, false],
  "Executioner"                => ["p17.png", 23, -15, 90, false],
  "Galilean Priest"            => ["p18.png", -2, -18, 100, false],
  "Golgotha"                   => ["p19.png", -4, 7, 100, false],
  "Inquisition Commissioner"   => ["p20.png", 2, -21, 95, false],
  "Knight of the Holy Sepulchre" => ["p21.png", -20, -13, 115, false],
  "Paladin of St Lazarus"      => ["p22.png", 20, -12, 90, false],
  "Prelate of the Flaming Sword" => ["p23.png", -14, 6, 80, false],
  "Scorpio Marksman"           => ["p24.png", -6, 16, 100, false],
  "Sepulchral Vanguard"        => ["p25.png", -5, 3, 100, false],
  "Seraph"                     => "p26.png",
  "Silere Priest"              => ["p27.png", 2, -1, 90, false],
  "Stigmatist"                 => ["p28.png", 2, -18, 110, false],
  "Summoner Priest"            => ["p29.png", 5, -11, 90, false],
  "Templar Marshal"            => ["p30.png", -17, -17, 90, false],
  "Throne"                     => ["p31.png", 7, -4, 95, false],
  "Venator of Devotion"        => ["p32.png", 0, -28, 90, false],
  "French Infantryman"         => ["p41_a.png", -10, 36, 180, true],
  "Inquisitorial Spy"          => ["p42.png", -20, -16, 100, false],
  "Knight of Malta"            => ["p43_a.png", 7, 61, 90, false],
  "Lacrimosa"                  => ["p44.png", 59, -22, 50, false],
  "Maltese Squire"             => ["p45_a.png", 7, -32, 90, false],
  "Martyr"                     => ["p46_a.png", 13, 10, 120, false],
  "Priest"                     => ["p47_a.png", 0, -18, 100, false],
  "Redemptionist"              => ["p48_a.png", 22, -26, 100, false],
  "Stalker"                    => ["p49.png", 1, -33, 85, false],
  "Thalassic Messenger"        => ["p50.png", 0, -11, 90, false],
  "Theophant of Sinai"         => ["p51.png", 10, 0, 95, false],
  "Witch Finder"               => ["p52.png", -10, -22, 85, false],
  "Thomas Thieme"              => ["p33.png", 11, -18, 85, false],
  "Altar Boy"                  => ["p34_a.png", 54, 1, 60, false],
  "Bishop Guard"               => ["p35_a.png", -32, 1, 100, false],
  "Celestial Congregation"     => ["p36.png", 13, -17, 85, false],
  "Celestial Spirit"           => ["p37_a.png", 8, 1, 100, false],
  "Cherubim"                   => ["p38_a.png", 14, -10, 85, false],
  "Chevaleresse"               => ["p39_a.png", 1, -10, 90, false],
  "Crucifier"                  => ["p40.png", -18, 3, 90, true],
  "Reliquary Page"             => ["p53.png", 11, -27, 85, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "vatican", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Altar Boy"          => ["p34_b.png", 27, -8, 65, false],
  "Bishop Guard"       => ["p35_b.png", 24, -22, 85, false],
  "Celestial Spirit"   => "p37_b.png",
  "Cherubim"           => ["p38_b.png", 10, -25, 85, false],
  "Chevaleresse"       => ["p39_b.png", 15, -19, 75, false],
  "French Infantryman" => ["p41_b.png", 17, -10, 100, false],
  "Knight of Malta"    => ["p43_b.png", 25, -9, 100, true],
  "Maltese Squire"     => "p45_b.png",
  "Martyr"             => ["p46_b.png", -2, 21, 85, false],
  "Priest"             => ["p47_b.png", 26, -29, 70, false],
  "Redemptionist"      => ["p48_b.png", 38, -23, 85, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "vatican", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

# ── Link CardReferences to Profiles ───────────────────────────────────────────
identifiers = card_ref_data.map { |a| a[:identifier] }
profile_map = Profile.where(faction: "vatican").each_with_object({}) { |p, h| h[p.name] = p.id }
CardReference.where(identifier: identifiers).find_each do |cr|
  base_name = cr.name.sub(/ \([AB]\)\z/, "")
  profile_id = profile_map[base_name]
  cr.update_columns(profile_id: profile_id) if profile_id && cr.profile_id != profile_id
end
cr_count = CardReference.where(identifier: identifiers).count
p_count  = Profile.where(faction: "vatican").count
puts "Seeded Vatican: #{cr_count} card references, #{p_count} profiles."
