equipment_data = [
  {
    name: "Flashbang Grenade",
    cost: 1,
    description: "Once per game, when disengaging, you may choose to automatically score a Critical instead of rolling any dice."
  },
  {
    name: "Bottled Courage",
    cost: 2,
    description: "Once per game, you may choose to re-roll a single dice (but not the Destiny Dice)."
  },
  {
    name: "Climbing Tools",
    cost: 2,
    description: "Once per game, when making a Run/Climb action, you may choose to automatically score a Critical instead of rolling any dice."
  },
  {
    name: "Limewater Rebreather",
    cost: 2,
    description: "Once per game, when making a Dive action, you may choose to automatically score a Critical instead of rolling any dice."
  },
  {
    name: "Lantern",
    cost: 2,
    description: "Once per game, at the start of a round, pick a friendly character. Until the end of the round, any character within 6\" (friendly or enemy) cannot claim any bonuses from being in cover and loses any Hidden counters they have."
  },
  {
    name: "Parachute",
    cost: 3,
    description: "Once per game, when Falling, you may choose to automatically score a 10 on the Destiny dice instead of rolling it."
  },
  {
    name: "Gondola",
    cost: 3,
    description: "You may set up a Gondola in water in your Deployment Zone at the start of the game."
  },
  {
    name: "Intercepted Documents",
    cost: 4,
    description: "Before deploying any characters, one friendly character gains the Infiltrate Character Ability."
  },
  {
    name: "Carnevale Mask",
    cost: 4,
    description: "Once per game, at the start of an enemy character's turn, pick a friendly character not in base contact with any enemy characters to wear this mask. For the enemy character's turn, this character cannot be attacked in any way (Combat actions, Drown actions, Magic spells etc)."
  },
  {
    name: "Poison",
    cost: 5,
    description: "Once per game, before rolling for a Combat action, the chosen weapon gains the Poisoned ability for this attack."
  },
  {
    name: "Leather Undershirt",
    cost: 10,
    description: "Once per game, when a friendly character has taken Damage, and before Protection rolls, roll 1 dice. Subtract that many points from the Damage received."
  }
]

equipment_data.each do |attrs|
  Catalog::Equipment.find_or_create_by!(name: attrs[:name]) do |e|
    e.cost = attrs[:cost]
    e.description = attrs[:description]
  end
end

puts "Seeded #{Catalog::Equipment.count} equipment items."
