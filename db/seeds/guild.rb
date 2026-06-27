# ── Card References ────────────────────────────────────────────────────────────
card_ref_data = [
  { name: "Capodecina",        identifier: "guild-capodecina",        cost: 20 },
  { name: "Harbourmaster",     identifier: "guild-harbourmaster",     cost: 21 },
  { name: "King For a Day",    identifier: "guild-king-for-a-day",   cost: 16 },
  { name: "Madame",            identifier: "guild-madame",            cost: 20 },
  { name: "Ostrich King?!",    identifier: "guild-ostrich-king",      cost: 19 },
  { name: "Prince of Thieves", identifier: "guild-prince-of-thieves", cost: 23 },
  { name: "Baba-Yaga",         identifier: "guild-baba-yaga",         cost: 19 },
  { name: "Black Lamp",        identifier: "guild-black-lamp",        cost: 17 },
  { name: "Ebenezer Chummage", identifier: "guild-ebenezer-chummage", cost: 18 },
  { name: "Ostrich Chariot?!", identifier: "guild-ostrich-chariot",   cost: 34 },
  { name: "Rialto Assassin",   identifier: "guild-rialto-assassin",   cost: 16 },
  { name: "Bloodletter",       identifier: "guild-bloodletter",       cost: 16 },
  { name: "Blood Matron",      identifier: "guild-blood-matron",      cost: 15 },
  { name: "Barber",            identifier: "guild-barber",            cost: 12 },
  { name: "Baroni",            identifier: "guild-baroni",            cost: 15 },
  { name: "Brewer",            identifier: "guild-brewer",            cost: 15 },
  { name: "Brute",             identifier: "guild-brute",             cost: 13 },
  { name: "Butcher",           identifier: "guild-butcher",           cost: 13 },
  { name: "Dancer",            identifier: "guild-dancer",            cost: 14 },
  { name: "Death Duellist",    identifier: "guild-death-duellist",    cost: 14 },
  { name: "Fisherman",         identifier: "guild-fisherman",         cost: 14 },
  { name: "Recruiter",         identifier: "guild-recruiter",         cost: 14 },
  { name: "Seamstress",        identifier: "guild-seamstress",        cost: 14 },
  { name: "Shadow Assassin",   identifier: "guild-shadow-assassin",   cost: 14 },
  { name: "Smuggler",          identifier: "guild-smuggler",          cost: 13 },
  { name: "Thief",             identifier: "guild-thief",             cost: 14 },
  { name: "Very Loud Ostrich", identifier: "guild-very-loud-ostrich", cost: 16 },
  { name: "Whaler",            identifier: "guild-whaler",            cost: 17 },
  { name: "Witch",             identifier: "guild-witch",             cost: 16 },
  { name: "Arbalest",          identifier: "guild-arbalest-a",        cost: 10 },
  { name: "Arbalest",          identifier: "guild-arbalest-b",        cost: 10 },
  { name: "Beggar",            identifier: "guild-beggar-a",          cost:  5 },
  { name: "Beggar",            identifier: "guild-beggar-b",          cost:  5 },
  { name: "Blooded",           identifier: "guild-blooded-a",         cost:  5 },
  { name: "Blooded",           identifier: "guild-blooded-b",         cost:  5 },
  { name: "Blood Courier",     identifier: "guild-blood-courier",     cost: 13 },
  { name: "Poacher",           identifier: "guild-poacher-a",         cost: 11 },
  { name: "Poacher",           identifier: "guild-poacher-b",         cost: 11 },
  { name: "Pulcinella",        identifier: "guild-pulcinella-a",      cost:  8 },
  { name: "Pulcinella",        identifier: "guild-pulcinella-b",      cost:  8 },
  { name: "Shipwright",        identifier: "guild-shipwright",        cost: 12 },
  { name: "Escort",            identifier: "guild-escort",            cost: 12 },
  { name: "Firebreather",      identifier: "guild-firebreather",      cost: 10 },
  { name: "Gondolier",         identifier: "guild-gondolier-a",       cost: 11 },
  { name: "Gondolier",         identifier: "guild-gondolier-b",       cost: 11 },
  { name: "Harlot",            identifier: "guild-harlot-a",          cost: 10 },
  { name: "Harlot",            identifier: "guild-harlot-b",          cost: 10 },
  { name: "Indebted",          identifier: "guild-indebted-a",        cost: 11 },
  { name: "Indebted",          identifier: "guild-indebted-b",        cost: 11 },
  { name: "Mariner",           identifier: "guild-mariner-a",         cost: 10 },
  { name: "Mariner",           identifier: "guild-mariner-b",         cost: 10 },
  { name: "Ostrich Rider",     identifier: "guild-ostrich-rider",     cost: 12 },
  { name: "Pilferer",          identifier: "guild-pilferer-a",        cost: 10 },
  { name: "Pilferer",          identifier: "guild-pilferer-b",        cost: 10 },
  { name: "Citizen",           identifier: "guild-citizen-a",         cost:  9 },
  { name: "Citizen",           identifier: "guild-citizen-b",         cost:  9 },
  { name: "Dog Keeper",        identifier: "guild-dog-keeper",        cost: 12 },
  { name: "Dog",               identifier: "guild-dog-a",             cost:  5 },
  { name: "Dog",               identifier: "guild-dog-b",             cost:  5 },
]


# ── Special Rules ──────────────────────────────────────────────────────────────

start_the_horrorshow = SpecialRule.find_or_create_by!(name: "Start the Horrorshow!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters with the End of Days keyword in line of sight gain +1 ATTACK."
end
do_as_i_say = SpecialRule.find_or_create_by!(name: "Do As I Say, Not As I Do") do |r|
  r.description = "All other friendly characters with the End of Days keyword lose Mindless for the entire game, even if this character is killed. This character still keeps Mindless."
end
fight_for_the_guild = SpecialRule.find_or_create_by!(name: "Fight For the Guild!") do |r|
  r.description = "PULSE Command Ability. One friendly character in line of sight with the Trade keyword replenishes 2 Will Points instead of 1 from Companion until the end of the game."
end
rise_up = SpecialRule.find_or_create_by!(name: "Rise Up") do |r|
  r.description = "All friendly characters with the Trade keyword gain Companion (Trade) as long as this character is on the board."
end
toughen_up = SpecialRule.find_or_create_by!(name: "Toughen Up") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 6\" gain Expert Protection (3)."
end
born_to_swim = SpecialRule.find_or_create_by!(name: "Born to Swim") do |r|
  r.description = "Other friendly characters add +2 to their Fast Swimmer number as long as this character is on the board. Friendly characters without Fast Swimmer instead gain Fast Swimmer (2)."
end
dont_let_them_take_you = SpecialRule.find_or_create_by!(name: "Don't Let Them Take You!") do |r|
  r.description = "PULSE Command Ability. One other friendly character in line of sight within 3\" (not including this one) gains Parry (2) until the end of the game."
end
strike_when_vulnerable = SpecialRule.find_or_create_by!(name: "Strike When They're Vulnerable") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any other friendly characters with the House of Virtue keyword in line of sight (not including this one) gain Penetration -2 on their weapons."
end
my_girls_and_boys = SpecialRule.find_or_create_by!(name: "My Girls & Boys") do |r|
  r.description = "While this character is on the board, all characters with the House of Virtue keyword gain Companion (House of Virtue)."
end
full_tilt = SpecialRule.find_or_create_by!(name: "Full Tilt!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters with the End of Days keyword in line of sight gain +1 MOVEMENT."
end
thieves_guild_training = SpecialRule.find_or_create_by!(name: "Thieves Guild Training") do |r|
  r.description = "PULSE Command Ability. One friendly character within 6\" gains Pickpocket until the end of the game."
end
take_it_for_the_guild = SpecialRule.find_or_create_by!(name: "Take it for the Guild!") do |r|
  r.description = "Any friendly characters in line of sight replenish 2 Will Points instead of 1 when Pickpocketing."
end
a_hero_among_thieves = SpecialRule.find_or_create_by!(name: "A Hero Among Thieves") do |r|
  r.description = "If this is the only character with the Leader keyword in the gang, this character loses the Hero keyword. However, if there is another character with the Leader keyword, this character loses the Leader keyword."
end
blood_rights = SpecialRule.find_or_create_by!(name: "Blood Rights") do |r|
  r.description = "1AP. Pick one character within 3\" (friendly or enemy). That character loses 1 Life Point, and this character replenishes 1 Will Point."
end
rally_to_the_light = SpecialRule.find_or_create_by!(name: "Rally to the Light!") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters in line of sight gain Companion (Black Lamp) and Brave."
end
the_lamp = SpecialRule.find_or_create_by!(name: "The Lamp") do |r|
  r.description = "This character may attempt to Dispel magic spells as if it has Mage (3) and Expert Sorcerer (3). In addition, enemy characters may not use Will Points when within 3\" of this character."
end
hearty_fish_soup = SpecialRule.find_or_create_by!(name: "Hearty Fish Soup") do |r|
  r.description = "PULSE Command Ability. All friendly characters with the Trade keyword within 6\" gain Brave and Expert Protection (1) until the end of this character's next turn."
end
a_choice_cut = SpecialRule.find_or_create_by!(name: "A Choice Cut") do |r|
  r.description = "When this character kills a character with the Monster keyword, it replenishes 1CP."
end
gifts_of_dried_meats = SpecialRule.find_or_create_by!(name: "Gifts of Dried Meats") do |r|
  r.description = "This character starts the game with 3 Dried Meats counters. At the end of its activation, you may use a Dried Meats counter to have another friendly character in base contact with this character replenish 2 Life Points."
end
uncoordinated_assault = SpecialRule.find_or_create_by!(name: "Uncoordinated Assault") do |r|
  r.description = "After this character makes a Combat action, it may make a single 0AP Attack of Opportunity using a weapon it did not attack with in that Combat action. Attacks of Opportunity from this rule cannot cause additional Attacks of Opportunity and do not count as Attacks of Opportunity from charging & charging from above."
end
levatesi_di_mezzo = SpecialRule.find_or_create_by!(name: "Levatesi di Mezzo, Imbecilli!") do |r|
  r.description = "This character may freely move over other characters as part of a Run/Climb action, but cannot end its action overlapping any other character. While making a Run/Climb action, this character ignores the normal rules for disengaging. At the end of this character's Run/Climb actions, make a Basic DEXTERITY roll. For each ace rolled, each character (friendly and enemy) moved over loses 1 Life Point. If the roll is a Fumble, this character receives a Stun counter."
end
magic_for_blood = SpecialRule.find_or_create_by!(name: "Magic for Blood") do |r|
  r.description = "Whenever this character successfully makes a Cast Spell action, it gains 2 Life Points. This can take this character above its Starting Life Points."
end
blood_for_magic = SpecialRule.find_or_create_by!(name: "Blood for Magic") do |r|
  r.description = "At the start of this character's turn, it may replenish up to 3 of its Will Points, costing 1 Life Point for each Will Point replenished."
end
go_for_the_eyes = SpecialRule.find_or_create_by!(name: "Go For the Eyes") do |r|
  r.description = "When a critical is scored by Pithing Needle in a Combat action, the applied Stun counter cannot be removed for the rest of the game and is unaffected by any spells or abilities."
end
prey_upon = SpecialRule.find_or_create_by!(name: "Prey Upon") do |r|
  r.description = "At the start of the game, nominate an enemy character to be this character's Prey. When this character makes a Combat action against its Prey, that combat action is a critical if the Destiny Dice is a 9 or a 10 and there is at least 1 other Ace in that roll."
end
intimidation = SpecialRule.find_or_create_by!(name: "Intimidation") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 3\" gain First Strike (1)."
end
twin_pistols = SpecialRule.find_or_create_by!(name: "Twin Pistols") do |r|
  r.description = "This character's weapons share the Reload ability - you may make 2 Combat actions with the Single Duelling Pistol or 1 with Twin Duelling Pistols in one round."
end
unwieldy = SpecialRule.find_or_create_by!(name: "Unwieldy") do |r|
  r.description = "This character may only make Combat actions with the Twin Duelling Pistols as the first action of their turn (including using it for Attacks of Opportunity)."
end
fancy_a_tipple = SpecialRule.find_or_create_by!(name: "Fancy a Tipple?") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters within 5\" gain Brave and First Strike (1)."
end
keep_it_flowing = SpecialRule.find_or_create_by!(name: "Keep it Flowing") do |r|
  r.description = "Any enemy character in base contact with this character can be the target of a Drown action, regardless of whether they're in water."
end
flambe = SpecialRule.find_or_create_by!(name: "Flambé") do |r|
  r.description = "This character may only use Flaming Bottles when within 3\" of a Pulcinella Firebreather."
end
thick_skull = SpecialRule.find_or_create_by!(name: "Thick Skull") do |r|
  r.description = "This character cannot receive Stunned counters."
end
communicative_dance = SpecialRule.find_or_create_by!(name: "Communicative Dance") do |r|
  r.description = "PULSE Command Ability. Pick one friendly character within 3\" and one different friendly character with the House of Virtue keyword within line of sight. Both of those characters make an immediate Run/Climb action. This movement cannot be used to charge, but can be used to disengage."
end
victory_rush = SpecialRule.find_or_create_by!(name: "Victory Rush") do |r|
  r.description = "When this character kills an enemy character with a Combat action, it gains your choice of either: an additional 1AP, replenish 4 Life Points, or replenish 2 Will Points."
end
bring_it_down = SpecialRule.find_or_create_by!(name: "Bring it Down!") do |r|
  r.description = "PULSE Command Ability. One friendly character within 6\" gains Hunter until the end of the game."
end
extortion = SpecialRule.find_or_create_by!(name: "Extortion") do |r|
  r.description = "AURA Command Ability. Until the end of the round, any friendly characters with the Henchman keyword within 6\" gain Bodyguard (Hero)."
end
instigator = SpecialRule.find_or_create_by!(name: "Instigator") do |r|
  r.description = "All friendly characters with Companion (Trade) gain +1 ATTACK while within 6\" of one or more characters with this special rule. Characters with the Instigator rule are unaffected."
end
entwined_magics = SpecialRule.find_or_create_by!(name: "Entwined Magics") do |r|
  r.description = "When picking spells for this character, the additional spells granted by Expert Sorcerer may be from any discipline it has access to (though it does not gain an additional cantrip if it is different)."
end
fade_to_the_shadow = SpecialRule.find_or_create_by!(name: "Fade to the Shadow") do |r|
  r.description = "2AP. If this character is within 1\" of impassable terrain, they can be removed from the board and then placed back down within 1\" of another piece of impassable terrain on ground level at least 6\" away from enemy characters."
end
smuggling = SpecialRule.find_or_create_by!(name: "Smuggling") do |r|
  r.description = "When you achieve an Agenda, one character within 6\" and line of sight replenishes 1 Command Point."
end
get_to_the_roof = SpecialRule.find_or_create_by!(name: "Get to the Roof") do |r|
  r.description = "PULSE Command Ability. One friendly character with the Henchman keyword within 6\" gains Acrobatic (3) until the end of the game."
end
toot_toot_charge = SpecialRule.find_or_create_by!(name: "Toot Toot Toot... Charge!") do |r|
  r.description = "PULSE Command Ability. Up to 2 friendly characters within 3\" may make an immediate Run/Climb action, but this movement must be used to charge an enemy (doesn't have to be the same enemy!)."
end
doot = SpecialRule.find_or_create_by!(name: "Doot") do |r|
  r.description = "Whenever this character makes a Combat action with its Trumpet weapon, all friendly characters within 3\" cheer and replenish 1 Will Point."
end
get_over_here = SpecialRule.find_or_create_by!(name: "Get Over Here") do |r|
  r.description = "A Whaling Lance's Knockback can move the target in any direction."
end
whispers_on_the_street = SpecialRule.find_or_create_by!(name: "Whispers on the Street") do |r|
  r.description = "For every friendly character with this ability in your gang at the start of the round, add a re-roll to your Mob Mentality Pool. Until the end of the round, any friendly character may use these re-rolls on any roll - one re-roll per dice."
end
hidden_in_plain_sight = SpecialRule.find_or_create_by!(name: "Hidden in Plain Sight") do |r|
  r.description = "This character can be deployed anywhere on the board at ground level, at least 6\" away from any enemy characters or objectives."
end
living_sacrifice = SpecialRule.find_or_create_by!(name: "Living Sacrifice") do |r|
  r.description = "Any character with the House of Virtue keyword within 6\" and line of sight may use this character's Life Points as if they were their own Will Points, costing 2 Life Points per Will Point. This ability can be used even if it would kill this character. If a Will Point granted by this ability would kill this character and be used on a Cast Spell action, the destiny dice is counted as automatically rolling a 10."
end
transfusion = SpecialRule.find_or_create_by!(name: "Transfusion") do |r|
  r.description = "1WP. One friendly character in base contact replenishes 1 Life Point or one enemy character loses 1 Life Point. If an enemy character is killed by this life loss, this character replenishes 2 Will Points. This character may do this once during each of its turns."
end
bucket_of_blood = SpecialRule.find_or_create_by!(name: "Bucket of Blood") do |r|
  r.description = "At the start of the game, when selecting spells, you may select a Blood Rites spell not known by any other friendly Mage for this character to store. While this character is within line of sight to a friendly Mage, that character can cast the stored spell as if it were their own."
end
encouragement = SpecialRule.find_or_create_by!(name: '"Encouragement"') do |r|
  r.description = "This character may only use the ORDER or COUNTER Commands on characters with the Henchman keyword."
end
sculler = SpecialRule.find_or_create_by!(name: "Sculler") do |r|
  r.description = "For each character with this ability, you may purchase 1 extra Gondola from the Equipment list. This character may be deployed in water or on a Gondola and may also re-roll failed dice rolls when making Row actions."
end
paying_off_my_debts = SpecialRule.find_or_create_by!(name: "Paying Off My Debts") do |r|
  r.description = "When this character kills an enemy character with a Combat action, add 1 re-roll to your Mob Mentality pool."
end
rope_arrow = SpecialRule.find_or_create_by!(name: "Rope Arrow") do |r|
  r.description = "2AP. Pick a point on a piece of vertical terrain within 12\" at least 1\" below this character. Move the character to that point as if moving down a zipline."
end

# ── Weapons ───────────────────────────────────────────────────────────────────

staff_of_credit       = Weapon.find_or_create_by!(name: "Staff of Credit")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -3; w.abilities = [] }
twin_blades           = Weapon.find_or_create_by!(name: "Twin Blades")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
clockwork_pistol      = Weapon.find_or_create_by!(name: "Clockwork Pistol")      { |w| w.range = 6;  w.evasion = 1;  w.damage = 1;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
sailors_knife         = Weapon.find_or_create_by!(name: "Sailor's Knife")        { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Aquatic"] }
garter_pistol         = Weapon.find_or_create_by!(name: "Garter Pistol")         { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = -2; w.abilities = ["Black Powder", "Reload (2)"] }
stiletto              = Weapon.find_or_create_by!(name: "Stiletto")              { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 1;  w.abilities = [] }
concealed_pistol      = Weapon.find_or_create_by!(name: "Concealed Pistol")      { |w| w.range = 4;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Black Powder", "Reload (1)", "Knockback"] }
gilded_sword          = Weapon.find_or_create_by!(name: "Gilded Sword")          { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
pestle                = Weapon.find_or_create_by!(name: "Pestle")                { |w| w.range = 1;  w.evasion = 0;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Knockback", "Two-handed"] }
sharpened_dagger      = Weapon.find_or_create_by!(name: "Sharpened Dagger")      { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
fishmongers_knives    = Weapon.find_or_create_by!(name: "Fishmonger's Knives")   { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
thrown_harpoon        = Weapon.find_or_create_by!(name: "Thrown Harpoon")        { |w| w.range = 4;  w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Reload (1)"] }
club                  = Weapon.find_or_create_by!(name: "Club")                  { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Stun"] }
bottle_burner         = Weapon.find_or_create_by!(name: "Bottle Burner")         { |w| w.range = 5;  w.evasion = 2;  w.damage = 1;  w.penetration = -1; w.abilities = ["Black Powder", "Blast"] }
bird_kick             = Weapon.find_or_create_by!(name: "Bird Kick")             { |w| w.range = 0;  w.evasion = 0;  w.damage = 2;  w.penetration = 0;  w.abilities = [] }
balanced_knife        = Weapon.find_or_create_by!(name: "Balanced Throwing Knife") { |w| w.range = 6; w.evasion = 0; w.damage = -1; w.penetration = -4; w.abilities = [] }
smoke_bomb            = Weapon.find_or_create_by!(name: "Smoke Bomb")            { |w| w.range = 6;  w.evasion = 1;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Blast", "Harmless", "Smoke", "Reload (1)"] }
dagger                = Weapon.find_or_create_by!(name: "Dagger")                { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
pithing_needle        = Weapon.find_or_create_by!(name: "Pithing Needle")        { |w| w.range = 0;  w.evasion = 1;  w.damage = 0;  w.penetration = -1; w.abilities = ["Stun"] }
straight_razor        = Weapon.find_or_create_by!(name: "Straight Razor")        { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -3; w.abilities = [] }
duelling_pistol       = Weapon.find_or_create_by!(name: "Duelling Pistol")       { |w| w.range = 8;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (2)"] }
twin_duelling_pistols = Weapon.find_or_create_by!(name: "Twin Duelling Pistols") { |w| w.range = 8;  w.evasion = 0;  w.damage = 3;  w.penetration = -1; w.abilities = ["Black Powder", "Reload (1)"] }
bottles               = Weapon.find_or_create_by!(name: "Bottles")               { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
flaming_bottles       = Weapon.find_or_create_by!(name: "Flaming Bottles")       { |w| w.range = 6;  w.evasion = 0;  w.damage = 0;  w.penetration = -5; w.abilities = ["Black Powder"] }
big_club              = Weapon.find_or_create_by!(name: "Big Club")              { |w| w.range = 1;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Knockback"] }
butchers_knives       = Weapon.find_or_create_by!(name: "Butcher's Knives")      { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
poisoned_needle       = Weapon.find_or_create_by!(name: "Poisoned Needle")       { |w| w.range = 0;  w.evasion = -1; w.damage = 0;  w.penetration = 1;  w.abilities = ["Poisoned"] }
rapier                = Weapon.find_or_create_by!(name: "Rapier")                { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = [] }
pole_spear_and_net    = Weapon.find_or_create_by!(name: "Pole Spear & Net")      { |w| w.range = 0;  w.evasion = -1; w.damage = 1;  w.penetration = 0;  w.abilities = ["Aquatic"] }
harpoon_gun           = Weapon.find_or_create_by!(name: "Harpoon Gun")           { |w| w.range = 12; w.evasion = 1;  w.damage = 1;  w.penetration = 0;  w.abilities = ["Reload (1)", "Two-handed"] }
handbow               = Weapon.find_or_create_by!(name: "Handbow")               { |w| w.range = 15; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Reload (2)"] }
unarmed               = Weapon.find_or_create_by!(name: "Unarmed")               { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 1;  w.abilities = [] }
dual_stilettos        = Weapon.find_or_create_by!(name: "Dual Stilettos")        { |w| w.range = 0;  w.evasion = -1; w.damage = 1;  w.penetration = 1;  w.abilities = [] }
blunderbuss           = Weapon.find_or_create_by!(name: "Blunderbuss")           { |w| w.range = 0;  w.evasion = -1; w.damage = 2;  w.penetration = 1;  w.abilities = ["Black Powder", "Reload (1)", "Template"] }
trumpet               = Weapon.find_or_create_by!(name: "Trumpet")               { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
whaling_lance         = Weapon.find_or_create_by!(name: "Whaling Lance")         { |w| w.range = 6;  w.evasion = 1;  w.damage = 3;  w.penetration = 0;  w.abilities = ["Knockback", "Two-handed"] }
crossbow              = Weapon.find_or_create_by!(name: "Crossbow")              { |w| w.range = 30; w.evasion = 0;  w.damage = 0;  w.penetration = -1; w.abilities = ["Reload (1)", "Two-handed"] }
improvised_weapon     = Weapon.find_or_create_by!(name: "Improvised Weapon")     { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
training_whip         = Weapon.find_or_create_by!(name: "Training Whip")         { |w| w.range = 3;  w.evasion = -1; w.damage = 0;  w.penetration = 0;  w.abilities = [] }
teeth                 = Weapon.find_or_create_by!(name: "Teeth")                 { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = [] }
sword                 = Weapon.find_or_create_by!(name: "Sword")                 { |w| w.range = 0;  w.evasion = 0;  w.damage = 1;  w.penetration = 0;  w.abilities = [] }
fire_breath           = Weapon.find_or_create_by!(name: "Fire Breath")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = -3; w.abilities = ["Black Powder", "Template", "Two-handed", "Reload (1)"] }
bladed_oar            = Weapon.find_or_create_by!(name: "Bladed Oar")            { |w| w.range = 2;  w.evasion = 0;  w.damage = 1;  w.penetration = -1; w.abilities = ["Two-handed"] }
short_bow             = Weapon.find_or_create_by!(name: "Short Bow")             { |w| w.range = 12; w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Reload (3)", "Two-handed"] }
short_sword           = Weapon.find_or_create_by!(name: "Short Sword")           { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = [] }
dive_knife            = Weapon.find_or_create_by!(name: "Dive Knife")            { |w| w.range = 0;  w.evasion = 0;  w.damage = 0;  w.penetration = 0;  w.abilities = ["Aquatic"] }
riveting_hammer       = Weapon.find_or_create_by!(name: "Riveting Hammer")       { |w| w.range = 0;  w.evasion = 0;  w.damage = 2;  w.penetration = 0;  w.abilities = ["Two-handed"] }

# ── Leaders ───────────────────────────────────────────────────────────────────

capodecina = Profile.find_or_create_by!(name: "Capodecina") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 3; p.life_points = 13; p.will_points = 4; p.command_points = 4
  p.size = 30; p.ducats = 20; p.movement = 5; p.dexterity = 6; p.attack = 4; p.protection = 2; p.mind = 4
  p.keywords = ["The Guild", "Leader", "Trade"]
  p.abilities = ["Aerial Attack", "Expert Offence (2)", "Infiltration"]
end
ProfileWeapon.find_or_create_by!(profile: capodecina, weapon: twin_blades) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: capodecina, special_rule: fight_for_the_guild) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: capodecina, special_rule: rise_up)             { |psr| psr.position = 1 }

harbourmaster = Profile.find_or_create_by!(name: "Harbourmaster") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 3; p.life_points = 14; p.will_points = 3; p.command_points = 4
  p.size = 30; p.ducats = 21; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["The Guild", "Leader"]
  p.abilities = ["Fast Swimmer (2)", "Parry (2)"]
end
ProfileWeapon.find_or_create_by!(profile: harbourmaster, weapon: clockwork_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: harbourmaster, weapon: sailors_knife)    { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: harbourmaster, special_rule: toughen_up)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: harbourmaster, special_rule: born_to_swim) { |psr| psr.position = 1 }

king_for_a_day = Profile.find_or_create_by!(name: "King For a Day") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 2
  p.size = 30; p.ducats = 16; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 3
  p.keywords = ["The Guild", "Leader", "End of Days"]
  p.abilities = ["Brave", "Companion (End of Days)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: king_for_a_day, weapon: staff_of_credit) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: king_for_a_day, special_rule: start_the_horrorshow) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: king_for_a_day, special_rule: do_as_i_say)          { |psr| psr.position = 1 }

madame = Profile.find_or_create_by!(name: "Madame") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 3; p.life_points = 12; p.will_points = 4; p.command_points = 4
  p.size = 30; p.ducats = 20; p.movement = 4; p.dexterity = 5; p.attack = 3; p.protection = 3; p.mind = 6
  p.keywords = ["The Guild", "Leader", "House of Virtue"]
  p.abilities = ["Concealment (+1)", "Parry (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: madame, weapon: garter_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: madame, weapon: stiletto)       { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: madame, special_rule: dont_let_them_take_you)  { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: madame, special_rule: strike_when_vulnerable)  { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: madame, special_rule: my_girls_and_boys)       { |psr| psr.position = 2 }

ostrich_king = Profile.find_or_create_by!(name: "Ostrich King?!") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 2
  p.size = 40; p.ducats = 19; p.movement = 7; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["The Guild", "Leader", "End of Days"]
  p.abilities = ["Bulky", "Companion (End of Days)", "First Strike (2)", "Limited Movement", "Mindless", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: ostrich_king, weapon: staff_of_credit) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ostrich_king, special_rule: full_tilt)   { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ostrich_king, special_rule: do_as_i_say) { |psr| psr.position = 1 }

prince_of_thieves = Profile.find_or_create_by!(name: "Prince of Thieves") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 3; p.life_points = 13; p.will_points = 2; p.command_points = 5
  p.size = 30; p.ducats = 23; p.movement = 5; p.dexterity = 5; p.attack = 5; p.protection = 4; p.mind = 5
  p.keywords = ["The Guild", "Leader", "Hero", "Unique"]
  p.abilities = ["Acrobatic (2)", "Expert Marksman (2)", "Pickpocket", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: prince_of_thieves, weapon: concealed_pistol) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: prince_of_thieves, weapon: gilded_sword)     { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: prince_of_thieves, special_rule: thieves_guild_training) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: prince_of_thieves, special_rule: take_it_for_the_guild)  { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: prince_of_thieves, special_rule: a_hero_among_thieves)   { |psr| psr.position = 2 }

# ── Heroes ────────────────────────────────────────────────────────────────────

baba_yaga = Profile.find_or_create_by!(name: "Baba-Yaga") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 7; p.command_points = 0
  p.size = 40; p.ducats = 19; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 3; p.mind = 6
  p.keywords = ["The Guild", "Hero", "Unique", "Discipline (Blood Rites, Wild Magic)"]
  p.abilities = ["Bulky", "Mage (3)", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: baba_yaga, weapon: pestle) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: baba_yaga, special_rule: blood_rights) { |psr| psr.position = 0 }

barber = Profile.find_or_create_by!(name: "Barber") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Hero", "Trade"]
  p.abilities = ["Expert Offence (1)", "Engage"]
end
ProfileWeapon.find_or_create_by!(profile: barber, weapon: straight_razor) { |pw| pw.position = 0 }

baroni = Profile.find_or_create_by!(name: "Baroni") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 3; p.command_points = 2
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 4
  p.keywords = ["The Guild", "Hero"]
  p.abilities = ["Expert Marksman (2)", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: baroni, weapon: duelling_pistol)       { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: baroni, weapon: twin_duelling_pistols) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: baroni, special_rule: intimidation)  { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: baroni, special_rule: twin_pistols)  { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: baroni, special_rule: unwieldy)      { |psr| psr.position = 2 }

black_lamp = Profile.find_or_create_by!(name: "Black Lamp") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 14; p.will_points = 5; p.command_points = 2
  p.size = 30; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 5
  p.keywords = ["The Guild", "Hero", "Unique", "Trade"]
  p.abilities = ["Brave", "Universal Shielding (4)"]
end
ProfileWeapon.find_or_create_by!(profile: black_lamp, weapon: sharpened_dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: black_lamp, special_rule: rally_to_the_light) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: black_lamp, special_rule: the_lamp)           { |psr| psr.position = 1 }

bloodletter = Profile.find_or_create_by!(name: "Bloodletter") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 2; p.mind = 5
  p.keywords = ["The Guild", "Hero", "House of Virtue", "Discipline (Blood Rites)"]
  p.abilities = ["Expert Sorcerer (1)", "Mage (2)"]
end
ProfileWeapon.find_or_create_by!(profile: bloodletter, weapon: dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: bloodletter, special_rule: magic_for_blood) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: bloodletter, special_rule: blood_for_magic) { |psr| psr.position = 1 }

blood_matron = Profile.find_or_create_by!(name: "Blood Matron") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 1
  p.size = 30; p.ducats = 15; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["The Guild", "Hero", "House of Virtue"]
  p.abilities = ["Mindless", "Vampiric Attack (2)"]
end
ProfileWeapon.find_or_create_by!(profile: blood_matron, weapon: pithing_needle) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_matron, special_rule: go_for_the_eyes) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_matron, special_rule: prey_upon)       { |psr| psr.position = 1 }

brewer = Profile.find_or_create_by!(name: "Brewer") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 2
  p.size = 40; p.ducats = 15; p.movement = 4; p.dexterity = 3; p.attack = 3; p.protection = 2; p.mind = 2
  p.keywords = ["The Guild", "Hero", "End of Days"]
  p.abilities = ["Companion (End of Days)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: brewer, weapon: bottles)        { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: brewer, weapon: flaming_bottles) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: brewer, special_rule: fancy_a_tipple)  { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: brewer, special_rule: keep_it_flowing) { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: brewer, special_rule: flambe)          { |psr| psr.position = 2 }

brute = Profile.find_or_create_by!(name: "Brute") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 14; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Hero", "End of Days"]
  p.abilities = ["Companion (End of Days)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: brute, weapon: big_club) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: brute, special_rule: thick_skull) { |psr| psr.position = 0 }

butcher = Profile.find_or_create_by!(name: "Butcher") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Hero", "Trade"]
  p.abilities = ["Brawler (1)", "Expert Grappler (2)"]
end
ProfileWeapon.find_or_create_by!(profile: butcher, weapon: butchers_knives) { |pw| pw.position = 0 }

dancer = Profile.find_or_create_by!(name: "Dancer") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 3
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 6; p.attack = 3; p.protection = 2; p.mind = 4
  p.keywords = ["The Guild", "Hero", "House of Virtue"]
  p.abilities = ["Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: dancer, weapon: poisoned_needle) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: dancer, special_rule: communicative_dance) { |psr| psr.position = 0 }

death_duellist = Profile.find_or_create_by!(name: "Death Duellist") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 2
  p.keywords = ["The Guild", "Hero", "House of Virtue"]
  p.abilities = ["Engage", "Expert Offence (2)", "Parry (2)"]
end
ProfileWeapon.find_or_create_by!(profile: death_duellist, weapon: rapier) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: death_duellist, special_rule: victory_rush) { |psr| psr.position = 0 }

ebenezer = Profile.find_or_create_by!(name: "Ebenezer Chummage") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 14; p.will_points = 3; p.command_points = 1
  p.size = 40; p.ducats = 18; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["The Guild", "Hero", "Trade", "Unique"]
  p.abilities = ["Brawler (2)", "Expert Grappler (2)", "Fast Swimmer (1)", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: ebenezer, weapon: fishmongers_knives) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: ebenezer, weapon: thrown_harpoon)     { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: ebenezer, special_rule: hearty_fish_soup)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ebenezer, special_rule: a_choice_cut)        { |psr| psr.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: ebenezer, special_rule: gifts_of_dried_meats) { |psr| psr.position = 2 }

fisherman = Profile.find_or_create_by!(name: "Fisherman") do |p|
  p.version = "2.2.1"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 4; p.mind = 3
  p.keywords = ["The Guild", "Hero"]
  p.abilities = ["Expert Offence (1)", "Fast Swimmer (2)", "Hunter"]
end
ProfileWeapon.find_or_create_by!(profile: fisherman, weapon: pole_spear_and_net) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: fisherman, weapon: harpoon_gun)        { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: fisherman, special_rule: bring_it_down) { |psr| psr.position = 0 }

ostrich_chariot = Profile.find_or_create_by!(name: "Ostrich Chariot?!") do |p|
  p.version = "2.2.1"; p.faction = "guild"
  p.action_points = 2; p.life_points = 30; p.will_points = 3; p.command_points = 0
  p.size = 75; p.ducats = 34; p.movement = 7; p.dexterity = 3; p.attack = 4; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Hero", "End of Days", "Unique"]
  p.abilities = ["Bulky", "Companion (End of Days)", "First Strike (2)", "Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: ostrich_chariot, weapon: club)          { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: ostrich_chariot, weapon: bottle_burner) { |pw| pw.position = 1 }
ProfileWeapon.find_or_create_by!(profile: ostrich_chariot, weapon: bird_kick)     { |pw| pw.position = 2 }
ProfileSpecialRule.find_or_create_by!(profile: ostrich_chariot, special_rule: uncoordinated_assault) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: ostrich_chariot, special_rule: levatesi_di_mezzo)     { |psr| psr.position = 1 }

rialto_assassin = Profile.find_or_create_by!(name: "Rialto Assassin") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 16; p.movement = 5; p.dexterity = 5; p.attack = 5; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Hero", "Unique"]
  p.abilities = ["Expert Marksman (3)", "Infiltration", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: rialto_assassin, weapon: balanced_knife) { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: rialto_assassin, weapon: smoke_bomb)     { |pw| pw.position = 1 }

recruiter = Profile.find_or_create_by!(name: "Recruiter") do |p|
  p.version = "2.2.1"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 3; p.command_points = 2
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["The Guild", "Hero", "Trade"]
  p.abilities = []
end
ProfileWeapon.find_or_create_by!(profile: recruiter, weapon: handbow) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: recruiter, special_rule: extortion)  { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: recruiter, special_rule: instigator) { |psr| psr.position = 1 }

seamstress = Profile.find_or_create_by!(name: "Seamstress") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 4; p.command_points = 0
  p.size = 30; p.ducats = 14; p.movement = 4; p.dexterity = 4; p.attack = 2; p.protection = 3; p.mind = 4
  p.keywords = ["The Guild", "Hero", "House of Virtue", "Discipline (Divinity, Fateweaving)"]
  p.abilities = ["Mage (1)", "Expert Sorcerer (1)"]
end
ProfileWeapon.find_or_create_by!(profile: seamstress, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: seamstress, special_rule: entwined_magics) { |psr| psr.position = 0 }

shadow_assassin = Profile.find_or_create_by!(name: "Shadow Assassin") do |p|
  p.version = "2.2.1"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 5; p.attack = 4; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Hero", "House of Virtue"]
  p.abilities = ["Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: shadow_assassin, weapon: dual_stilettos) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: shadow_assassin, special_rule: fade_to_the_shadow) { |psr| psr.position = 0 }

smuggler = Profile.find_or_create_by!(name: "Smuggler") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 12; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["The Guild", "Hero"]
  p.abilities = ["Boat Crew", "Concealment (+1)"]
end
ProfileWeapon.find_or_create_by!(profile: smuggler, weapon: blunderbuss) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: smuggler, special_rule: smuggling) { |psr| psr.position = 0 }

thief = Profile.find_or_create_by!(name: "Thief") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 3; p.command_points = 1
  p.size = 30; p.ducats = 14; p.movement = 5; p.dexterity = 5; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["The Guild", "Hero"]
  p.abilities = ["Aerial Attack", "Infiltration", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: thief, weapon: stiletto)   { |pw| pw.position = 0 }
ProfileWeapon.find_or_create_by!(profile: thief, weapon: smoke_bomb) { |pw| pw.position = 1 }
ProfileSpecialRule.find_or_create_by!(profile: thief, special_rule: get_to_the_roof) { |psr| psr.position = 0 }

very_loud_ostrich = Profile.find_or_create_by!(name: "Very Loud Ostrich") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 14; p.will_points = 3; p.command_points = 2
  p.size = 40; p.ducats = 16; p.movement = 7; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Hero", "End of Days"]
  p.abilities = ["Bulky", "Companion (End of Days)", "First Strike (2)", "Limited Movement", "Mindless", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: very_loud_ostrich, weapon: trumpet) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: very_loud_ostrich, special_rule: toot_toot_charge) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: very_loud_ostrich, special_rule: doot)             { |psr| psr.position = 1 }

whaler = Profile.find_or_create_by!(name: "Whaler") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 15; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 17; p.movement = 4; p.dexterity = 4; p.attack = 4; p.protection = 2; p.mind = 3
  p.keywords = ["The Guild", "Hero"]
  p.abilities = ["Boat Crew", "Hunter", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: whaler, weapon: whaling_lance) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: whaler, special_rule: get_over_here) { |psr| psr.position = 0 }

witch = Profile.find_or_create_by!(name: "Witch") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 4; p.command_points = 2
  p.size = 30; p.ducats = 16; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 5
  p.keywords = ["The Guild", "Hero", "House of Virtue", "Discipline (Blood Rites, Runes of Sovereignty, Wild Magic)"]
  p.abilities = ["Mage (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: witch, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: witch, special_rule: blood_rights) { |psr| psr.position = 0 }

# ── Henchmen ──────────────────────────────────────────────────────────────────

arbalest = Profile.find_or_create_by!(name: "Arbalest") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 4; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "Trade"]
  p.abilities = ["Companion (Trade)"]
end
ProfileWeapon.find_or_create_by!(profile: arbalest, weapon: crossbow) { |pw| pw.position = 0 }

beggar = Profile.find_or_create_by!(name: "Beggar") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 5; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 3; p.mind = 2
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Concealment (+2)"]
end
ProfileWeapon.find_or_create_by!(profile: beggar, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: beggar, special_rule: whispers_on_the_street) { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: beggar, special_rule: hidden_in_plain_sight)  { |psr| psr.position = 1 }

blooded = Profile.find_or_create_by!(name: "Blooded") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 5; p.movement = 4; p.dexterity = 3; p.attack = 2; p.protection = 1; p.mind = 1
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Mindless", "Limited Movement"]
end
ProfileWeapon.find_or_create_by!(profile: blooded, weapon: unarmed) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blooded, special_rule: living_sacrifice) { |psr| psr.position = 0 }

blood_courier = Profile.find_or_create_by!(name: "Blood Courier") do |p|
  p.version = "2.3.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 13; p.movement = 5; p.dexterity = 3; p.attack = 2; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "House of Virtue"]
  p.abilities = ["Concealment (2)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: blood_courier, weapon: dagger) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_courier, special_rule: transfusion)    { |psr| psr.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: blood_courier, special_rule: bucket_of_blood) { |psr| psr.position = 1 }

citizen = Profile.find_or_create_by!(name: "Citizen") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 9; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "Trade"]
  p.abilities = ["Companion (Trade)"]
end
ProfileWeapon.find_or_create_by!(profile: citizen, weapon: improvised_weapon) { |pw| pw.position = 0 }

dog_keeper = Profile.find_or_create_by!(name: "Dog Keeper") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 2
  p.size = 30; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Companion (Dog)", "Engage"]
end
ProfileWeapon.find_or_create_by!(profile: dog_keeper, weapon: training_whip) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: dog_keeper, special_rule: encouragement) { |psr| psr.position = 0 }

dog = Profile.find_or_create_by!(name: "Dog") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 6; p.will_points = 0; p.command_points = 0
  p.size = 30; p.ducats = 5; p.movement = 6; p.dexterity = 5; p.attack = 2; p.protection = 1; p.mind = 1
  p.keywords = ["The Guild", "Henchman", "Dog"]
  p.abilities = ["Engage", "Limited Movement", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: dog, weapon: teeth) { |pw| pw.position = 0 }

escort = Profile.find_or_create_by!(name: "Escort") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "House of Virtue"]
  p.abilities = ["Bodyguard (Hero, Henchman)", "Expert Grappler (1)"]
end
ProfileWeapon.find_or_create_by!(profile: escort, weapon: sword) { |pw| pw.position = 0 }

firebreather = Profile.find_or_create_by!(name: "Firebreather") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 9; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Henchman", "End of Days"]
  p.abilities = ["Companion (End of Days)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: firebreather, weapon: fire_breath) { |pw| pw.position = 0 }

gondolier = Profile.find_or_create_by!(name: "Gondolier") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "Trade"]
  p.abilities = ["Brave", "Fast Swimmer (1)"]
end
ProfileWeapon.find_or_create_by!(profile: gondolier, weapon: bladed_oar) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: gondolier, special_rule: sculler) { |psr| psr.position = 0 }

harlot = Profile.find_or_create_by!(name: "Harlot") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 3
  p.keywords = ["The Guild", "Henchman", "House of Virtue"]
  p.abilities = ["Concealment (+1)", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: harlot, weapon: stiletto) { |pw| pw.position = 0 }

indebted = Profile.find_or_create_by!(name: "Indebted") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 1
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["First Strike (2)"]
end
ProfileWeapon.find_or_create_by!(profile: indebted, weapon: short_sword) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: indebted, special_rule: paying_off_my_debts) { |psr| psr.position = 0 }

mariner = Profile.find_or_create_by!(name: "Mariner") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 11; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 3
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Boat Crew", "Fast Swimmer (2)"]
end
ProfileWeapon.find_or_create_by!(profile: mariner, weapon: dive_knife) { |pw| pw.position = 0 }

ostrich_rider = Profile.find_or_create_by!(name: "Ostrich Rider") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 2; p.command_points = 0
  p.size = 40; p.ducats = 12; p.movement = 7; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Henchman", "End of Days"]
  p.abilities = ["Bulky", "Companion (End of Days)", "First Strike (2)", "Limited Movement", "Mindless", "Slippery"]
end
ProfileWeapon.find_or_create_by!(profile: ostrich_rider, weapon: club) { |pw| pw.position = 0 }

pilferer = Profile.find_or_create_by!(name: "Pilferer") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 8; p.will_points = 3; p.command_points = 0
  p.size = 30; p.ducats = 10; p.movement = 5; p.dexterity = 6; p.attack = 2; p.protection = 2; p.mind = 2
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Concealment (+1)", "Pickpocket"]
end
ProfileWeapon.find_or_create_by!(profile: pilferer, weapon: dagger) { |pw| pw.position = 0 }

poacher = Profile.find_or_create_by!(name: "Poacher") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 10; p.will_points = 2; p.command_points = 0
  p.size = 30; p.ducats = 11; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Concealment (+1)", "Infiltration"]
end
ProfileWeapon.find_or_create_by!(profile: poacher, weapon: short_bow) { |pw| pw.position = 0 }
ProfileSpecialRule.find_or_create_by!(profile: poacher, special_rule: rope_arrow) { |psr| psr.position = 0 }

pulcinella = Profile.find_or_create_by!(name: "Pulcinella") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 9; p.will_points = 1; p.command_points = 0
  p.size = 30; p.ducats = 8; p.movement = 5; p.dexterity = 4; p.attack = 3; p.protection = 2; p.mind = 1
  p.keywords = ["The Guild", "Henchman", "End of Days"]
  p.abilities = ["Companion (End of Days)", "Mindless"]
end
ProfileWeapon.find_or_create_by!(profile: pulcinella, weapon: club) { |pw| pw.position = 0 }

shipwright = Profile.find_or_create_by!(name: "Shipwright") do |p|
  p.version = "2.2.0"; p.faction = "guild"
  p.action_points = 2; p.life_points = 13; p.will_points = 1; p.command_points = 0
  p.size = 40; p.ducats = 12; p.movement = 4; p.dexterity = 4; p.attack = 3; p.protection = 3; p.mind = 2
  p.keywords = ["The Guild", "Henchman"]
  p.abilities = ["Expert Offence (2)"]
end
ProfileWeapon.find_or_create_by!(profile: shipwright, weapon: riveting_hammer) { |pw| pw.position = 0 }

# ── Illustrations ─────────────────────────────────────────────────────────────
# Page N of the PDF → pN.png. Page 1 is the faction rules page (no profile).
# Pages 31-33, 35, 37, 40-43, 45-47 produced _a/_b variants; _a is used as primary.
{
  "Capodecina"        => ["p02.png", -19, -5, 100, false],
  "Harbourmaster"     => ["p03.png", 9, -29, 90, true],
  "King For a Day"    => ["p04.png", 7, -14, 95, false],
  "Madame"            => ["p05.png", -8, -25, 100, false],
  "Ostrich King?!"    => ["p06.png", 13, -23, 85, false],
  "Prince of Thieves" => ["p07.png", 7, -18, 100, false],
  "Baba-Yaga"         => ["p08.png", -1, -3, 100, false],
  "Black Lamp"        => ["p09.png", -7, 4, 100, false],
  "Ebenezer Chummage" => ["p10.png", 26, -16, 80, false],
  "Ostrich Chariot?!" => ["p11.png", 12, -14, 90, false],
  "Rialto Assassin"   => ["p12.png", 0, -6, 90, false],
  "Bloodletter"       => "p13.png",
  "Blood Matron"      => ["p14.png", 51, -1, 80, false],
  "Barber"            => ["p15.png", -2, -16, 110, false],
  "Baroni"            => "p16.png",
  "Brewer"            => ["p17.png", -16, 0, 100, true],
  "Brute"             => ["p18.png", 9, -25, 85, false],
  "Butcher"           => ["p19.png", 1, -11, 90, false],
  "Dancer"            => ["p20.png", 10, 1, 100, false],
  "Death Duellist"    => ["p21.png", 25, -4, 85, false],
  "Fisherman"         => ["p22.png", 28, -13, 100, false],
  "Recruiter"         => ["p23.png", 24, -13, 85, false],
  "Seamstress"        => ["p24.png", -19, 3, 90, false],
  "Shadow Assassin"   => ["p25.png", 15, -24, 80, false],
  "Smuggler"          => ["p26.png", 36, -16, 70, false],
  "Thief"             => ["p27.png", 6, -13, 85, false],
  "Very Loud Ostrich" => ["p28.png", 6, -37, 100, false],
  "Whaler"            => ["p29.png", 0, -23, 90, false],
  "Witch"             => ["p30.png", 34, -18, 80, false],
  "Arbalest"          => ["p31_a.png", -1, -6, 90, false],
  "Beggar"            => ["p32_a.png", 42, -19, 75, false],
  "Blooded"           => ["p33_a.png", 61, -17, 70, false],
  "Blood Courier"     => ["p34.png", 60, -23, 65, true],
  "Poacher"           => ["p46_a.png", 30, -17, 85, false],
  "Pulcinella"        => ["p47_a.png", 19, -9, 75, false],
  "Shipwright"        => ["p48.png", 16, -9, 85, false],
  "Escort"            => ["p38.png", -4, -20, 85, false],
  "Firebreather"      => "p39.png",
  "Gondolier"         => ["p40_a.png", 2, -31, 150, false],
  "Harlot"            => ["p41_a.png", 18, -15, 90, false],
  "Indebted"          => ["p42_a.png", 2, -22, 90, false],
  "Mariner"           => ["p43_a.png", 24, -11, 100, false],
  "Ostrich Rider"     => ["p44.png", 20, -23, 85, false],
  "Pilferer"          => ["p45_a.png", 33, -28, 75, false],
  "Citizen"           => ["p35_a.png", 20, -13, 80, false],
  "Dog Keeper"        => ["p36.png", 3, -20, 85, false],
  "Dog"               => ["p37_a.png", 38, -43, 90, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "guild", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 1).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

{
  "Arbalest"   => "p31_b.png",
  "Beggar"     => ["p32_b.png", 19, -27, 85, false],
  "Blooded"    => ["p33_b.png", 51, -8, 70, false],
  "Citizen"    => ["p35_b.png", 18, -7, 75, true],
  "Dog"        => ["p37_b.png", -26, -50, 85, false],
  "Gondolier"  => ["p40_b.png", -47, -27, 100, false],
  "Harlot"     => ["p41_b.png", 34, -22, 80, false],
  "Indebted"   => ["p42_b.png", 51, -21, 80, false],
  "Mariner"    => "p43_b.png",
  "Pilferer"   => ["p45_b.png", 53, -48, 70, false],
  "Poacher"    => ["p46_b.png", 24, 6, 70, false],
  "Pulcinella" => ["p47_b.png", 63, -24, 55, false],
}.each do |name, val|
  profile = Profile.find_by(faction: "guild", name: name)
  next unless profile
  path, ox, oy, zoom, flipped = val.is_a?(Array) ? val : [val, 0, 0, 100, false]
  Illustration.find_or_initialize_by(profile: profile, number: 2).update!(
    path: path, offset_x: ox, offset_y: oy, zoom: zoom, flipped: flipped
  )
end

# ── Card References ────────────────────────────────────────────────────────────
profile_map = Profile.where(faction: "guild").each_with_object({}) { |p, h| h[p.name] = p.id }
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
p_count  = Profile.where(faction: "guild").count
puts "Seeded Guild: #{cr_count} card references, #{p_count} profiles."
