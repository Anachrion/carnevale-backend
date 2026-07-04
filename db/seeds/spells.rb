spells_by_discipline = {
  blood_rites: [
    {
      name: "Cantrip of the Devil",
      cost: 0,
      difficulty: 7,
      description: "Pick one enemy character in line of sight within 3\". Choose for that character to either lose 1 Life Point, or take 2 Damage with Penetration -2."
    },
    {
      name: "Boiling Veins",
      cost: 1,
      difficulty: 3,
      description: "Total up every Ace rolled then minus (X). Pick one enemy character in line of sight within 8\". That character takes that much Damage with Penetration (-X). If this spell reduces a character to 0 Life Points, before removing the character, place the Blast template centred on the character. Any character (friendly or enemy) touched by the template loses Life Points equal to every Ace rolled."
    },
    {
      name: "Bloodlust",
      cost: 1,
      difficulty: 6,
      description: "Pick one character in line of sight within 6\". That character loses 1 Life Point and gains +(X) ATTACK until the end of its next turn."
    },
    {
      name: "Blood Drain",
      cost: 1,
      difficulty: 7,
      description: "Pick one enemy character in line of sight within 6\". That character takes (X) Damage with Penetration -4. If the target loses at least 1 Life Point, any friendly character within 6\" of the target replenishes (X) Life Points."
    },
    {
      name: "Kraken's Breath",
      cost: 2,
      difficulty: 6,
      description: "Place the narrow end of the teardrop shaped template in base contact with the casting character. Any character (friendly or enemy) at least partially touched by the template takes (X)+2 Damage with Penetration -(X)."
    },
    {
      name: "Mother Hydra's Claws",
      cost: 2,
      difficulty: 6,
      description: "Total up every Ace rolled plus (X). You cause this many Life Points to be lost in total to (X) number of characters in line of sight within 6\", sharing the amount as equally as possible. If there aren't enough characters to target, the casting character can be counted multiple times."
    },
    {
      name: "Abyssal Mist",
      cost: 2,
      difficulty: 8,
      description: "Place the Blast marker anywhere in line of sight within 12\" on solid ground. Line of sight cannot be drawn through the Blast marker. At the end of the round, any characters at least partially over the Blast marker receive a Stunned counter. Then remove the Blast marker."
    }
  ],
  divinity: [
    {
      name: "Cantrip of the Sun",
      cost: 0,
      difficulty: 7,
      description: "Pick one friendly character in line of sight within 6\". That character replenishes 1 Life Point and 1 Will Point."
    },
    {
      name: "Protection of the Eye",
      cost: 1,
      difficulty: 5,
      description: "Pick one friendly character in line of sight within 6\". That character gains Universal Shielding (X)+3 until the end of its next turn."
    },
    {
      name: "Eldritch Armour",
      cost: 1,
      difficulty: 6,
      description: "Pick one friendly character in line of sight within 6\". That character gains +(X) PROTECTION until the end of its next turn."
    },
    {
      name: "Rejuvenation",
      cost: 1,
      difficulty: 7,
      description: "Total up every Ace rolled plus (X). Replenish this many Life Points in total from any number of characters within 12\" in line of sight, distributing the amount between the characters as you wish."
    },
    {
      name: "Holy Light",
      cost: 1,
      difficulty: 8,
      description: "All enemy characters with the Mage ability within 6\" receive a Stunned counter and lose (X) Life Points."
    },
    {
      name: "Defender of Destiny",
      cost: 1,
      difficulty: 8,
      description: "All friendly characters within 6\" gain Parry (X) and Expert Protection (X) until the end of the round."
    },
    {
      name: "Aqua Curitiva",
      cost: 2,
      difficulty: 8,
      description: "Pick one friendly character in line of sight within 6\". Place the Blast marker under this character. At the end of the round, any friendly characters at least partially over the Blast marker replenish (X)+2 Life Points. Any enemy characters at least partially over the Blast marker receive a Stunned counter. Then remove the Blast marker."
    }
  ],
  fateweaving: [
    {
      name: "Cantrip of the Stars",
      cost: 0,
      difficulty: 5,
      description: "Until the start of this character's next turn, you may re-roll the Destiny Dice once, even though not usually able to, for whatever roll you wish."
    },
    {
      name: "Marksman's Fortune",
      cost: 1,
      difficulty: 4,
      description: "Pick one character (friendly or enemy) in line of sight within 18\". Any weapons that character has with Reload (X) must add or subtract 1 from the (X) value until the end of the round (caster's choice)."
    },
    {
      name: "Otherworldly Oddity",
      cost: 1,
      difficulty: 5,
      description: "Pick one terrain feature with a footprint of 6\" or less in line of sight within 12\" with no characters on or in it. Until the start of this character's next turn, any friendly characters making movement actions on or in that terrain feature gain Acrobatic (X). Any enemy characters count that terrain feature as impassable terrain."
    },
    {
      name: "Blessing of the Sky",
      cost: 1,
      difficulty: 7,
      description: "Pick one friendly character in line of sight within 6\". Until the end of its next turn, that character gains +(X) to be distributed between its ATTACK, DEXTERITY, and/or MIND in any combination. A character may only be affected by Blessing of the Sky once at a time."
    },
    {
      name: "Curse of the Rent",
      cost: 1,
      difficulty: 7,
      description: "Pick one enemy character in line of sight within 6\". Until the end of its next turn, that character receives -(X) to be distributed by the caster between its ATTACK, DEXTERITY, and/or MIND in any combination. A character may only be affected by Curse of the Rent once at a time."
    },
    {
      name: "Glimpse of Glory",
      cost: 1,
      difficulty: 8,
      description: "Pick one friendly character in line of sight within 6\". That character gains Parry (X), Expert Offence (X), Expert Marksman (X), and Expert Protection (X) until the end of their next turn."
    },
    {
      name: "Fate's Bounty",
      cost: 2,
      difficulty: 4,
      description: "Total up every Ace rolled plus (X). Until the start of this character's next turn, you may re-roll this many dice (not the Destiny Dice), for whatever rolls you wish."
    }
  ],
  runes_of_sovereignty: [
    {
      name: "Cantrip of the Chariot",
      cost: 0,
      difficulty: 7,
      description: "Pick one friendly character in line of sight within 6\" that isn't in base contact with an enemy. That character immediately makes a Run/Climb action that cannot move into base contact with an enemy."
    },
    {
      name: "Renewed Vigour",
      cost: 1,
      difficulty: 6,
      description: "Pick (X) friendly characters in line of sight within 12\". Those characters remove any Stunned counters they have, and cannot gain Stunned counters until the end of the round."
    },
    {
      name: "Fiery Rhetoric",
      cost: 1,
      difficulty: 7,
      description: "Pick one friendly character in line of sight within 1\". That character replenishes 1 Command Point."
    },
    {
      name: "Waves of Force",
      cost: 1,
      difficulty: 8,
      description: "Pick a point in water in line of sight within 6\". Then pick another point within line of sight of the caster and 6\" of the first point. Trace an imaginary line between the two points. If that line does not pass through Impassable Terrain, any character touched by that line no higher than 3\" above the first point gets hit by a Grapple action, with the roll equal to the number of aces in the Magic Roll."
    },
    {
      name: "Walk Between Worlds",
      cost: 2,
      difficulty: 6,
      description: "Pick one friendly character in line of sight within 6\". That character gains Ethereal, Flight, and Slippery until the end of its next turn."
    },
    {
      name: "Ice Lock",
      cost: 2,
      difficulty: 6,
      description: "Place the Blast marker in water in line of sight within 8\". Any characters at least partially over the Blast marker receive a Stunned counter and are moved the shortest distance until they're not over the Blast marker. The area under the Blast marker is treated as solid ground. Remove the Blast marker at the end of the round."
    },
    {
      name: "Madness",
      cost: 2,
      difficulty: 8,
      description: "Pick one enemy character in line of sight within 3\". That character immediately makes an action. For the purpose of the action, the enemy character counts as a friendly character, with the caster's player deciding where to move them and making any rolls or additional actions (such as Attacks of Opportunity). This does not count towards their 3AP for the round. Always ask your opponent to handle their own models!"
    }
  ],
  wild_magic: [
    {
      name: "Cantrip of Justice",
      cost: 0,
      difficulty: 7,
      description: "This character may immediately cast another magic spell for 0AP. This spell costs Will Points as normal, but can be any spell known by any other mage (friendly or enemy) within line of sight."
    },
    {
      name: "They Sleep Underwater",
      cost: 1,
      difficulty: 5,
      description: "Pick (X) friendly characters in line of sight within 12\". Those characters gain Fast Swimmer (X) until the end of the round."
    },
    {
      name: "Healing",
      cost: 1,
      difficulty: 5,
      description: "Pick one friendly character in line of sight within 6\". That character replenishes (X) Life Points."
    },
    {
      name: "Summon Vermin",
      cost: 1,
      difficulty: 5,
      description: "Pick one enemy character in line of sight within 12\" and place the Blast marker over that character. Total up every ace plus (X), that character takes that much Damage and all other characters (friendly and enemy) under the marker take (X)-1 Damage."
    },
    {
      name: "Gateway",
      cost: 1,
      difficulty: 8,
      description: "Pick one character within 1\". Remove this character and place them anywhere out of base contact on solid ground within 8\". This removal or placement cannot cause Attacks of Opportunity."
    },
    {
      name: "Groundsnap",
      cost: 2,
      difficulty: 7,
      description: "Place the Blast marker on solid ground in line of sight within 8\". Any characters at least partially over the Blast marker take (X) Damage and are moved the shortest distance until they're not under the Blast marker. The area under the Blast marker is treated as impassable terrain. Remove the Blast marker at the end of the round."
    },
    {
      name: "Sunder Armour",
      cost: 2,
      difficulty: 7,
      description: "Pick one enemy character in line of sight within 6\". That character receives a total of -3 and -(X) to its PROTECTION until the end of the round."
    }
  ]
}

spells_by_discipline.each do |discipline, spells|
  spells.each_with_index do |attrs, index|
    Catalog::Spell.find_or_create_by!(name: attrs[:name], discipline: discipline) do |s|
      s.cost = attrs[:cost]
      s.difficulty = attrs[:difficulty]
      s.description = attrs[:description]
      s.cantrip = index.zero?
    end
  end
end

puts "Seeded #{Catalog::Spell.count} spells."
