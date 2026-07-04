# ── Agendas ─────────────────────────────────────────────────────────────────────

[
  # 1st Roll: 1-3
  { first_roll: "1-3", second_roll: 1, name: "Heroic Duel", description: "Kill an enemy character with the Leader keyword with a friendly character with the Leader keyword." },
  { first_roll: "1-3", second_roll: 2, name: "Hostile Takeover", description: "Kill an enemy character with the Leader keyword with a friendly character with the Hero keyword." },
  { first_roll: "1-3", second_roll: 3, name: "Ideas Above Your Station", description: "Kill an enemy character with either the Leader or Hero keywords with a friendly character with the Henchman keyword." },
  { first_roll: "1-3", second_roll: 4, name: "Inspiring Leadership", description: "Have a friendly character with the Leader keyword in base contact with 2 or more enemy characters at the same time." },
  { first_roll: "1-3", second_roll: 5, name: "Decoy", description: "Have a friendly character with either the Hero or Henchman keywords in base contact with 3 or more enemy characters at the same time." },
  { first_roll: "1-3", second_roll: 6, name: "Bully", description: "Grapple an enemy character into base contact with a friendly character." },
  { first_roll: "1-3", second_roll: 7, name: "One-Person Army", description: "Kill 3 enemy characters with a friendly character with the Leader keyword." },
  { first_roll: "1-3", second_roll: 8, name: "Cut Them Down", description: "Kill 3 enemy characters with any number of friendly characters with the Hero keyword." },
  { first_roll: "1-3", second_roll: 9, name: "Blood Frenzy", description: "Kill 3 enemy characters with any number of friendly characters with the Henchman keyword." },
  { first_roll: "1-3", second_roll: 10, name: "The Gods Guide Us", description: "Use all of the Will Points of at least 3 friendly characters that start the game with Will Points." },

  # 1st Roll: 4-6
  { first_roll: "4-6", second_roll: 1, name: "Will be Done", description: "Use 6 Will Points in a single round." },
  { first_roll: "4-6", second_roll: 2, name: "Lead From the Front", description: "Use all of the Command Points of at least 2 friendly characters that start the game with Command Points." },
  { first_roll: "4-6", second_roll: 3, name: "Following Orders", description: "Use 2 Command Abilities in a single round." },
  { first_roll: "4-6", second_roll: 4, name: "Scouting the Land", description: "Have 3 friendly characters at least 6\" above ground level on any point of the board outside of your deployment zone." },
  { first_roll: "4-6", second_roll: 5, name: "Approach by Water", description: "Have 3 friendly characters without the Water Creature special rule in water outside of your deployment zone." },
  { first_roll: "4-6", second_roll: 6, name: "Acrobatic Display", description: "Make 3 successful Jump actions that move at least 4\" in a single character's turn." },
  { first_roll: "4-6", second_roll: 7, name: "Watery Grave", description: "Kill an enemy character with a Drown action." },
  { first_roll: "4-6", second_roll: 8, name: "Let the Tide Take Them", description: "Perform a Drown action on 3 different enemy characters." },
  { first_roll: "4-6", second_roll: 9, name: "Death From Above", description: "Make 2 charges from above with 1 friendly character." },
  { first_roll: "4-6", second_roll: 10, name: "Draw Them In", description: "Disengage 2 times with 1 friendly character." },

  # 1st Roll: 7-9
  { first_roll: "7-9", second_roll: 1, name: "No Mercy", description: "Cause at least 8 points of Damage to an enemy character during a single character's turn." },
  { first_roll: "7-9", second_roll: 2, name: "Venetian Sniper", description: "Kill an enemy character with Combat action from at least 6\" away." },
  { first_roll: "7-9", second_roll: 3, name: "Get Them Wet", description: "Grapple 2 enemy characters into a canal." },
  { first_roll: "7-9", second_roll: 4, name: "Unholy Power", description: "Successfully make 3 Cast Spell actions in a single turn." },
  { first_roll: "7-9", second_roll: 5, name: "Hold Ground", description: "Make Guard actions with 3 friendly characters in 1 round." },
  { first_roll: "7-9", second_roll: 6, name: "Silence the Witch", description: "Attempt to Dispel 3 enemy Magic Spells." },
  { first_roll: "7-9", second_roll: 7, name: "Follow Your Fate", description: "Re-roll 6 dice in 1 round." },
  { first_roll: "7-9", second_roll: 8, name: "Over the Rooftops", description: "Make 4 successful Jump actions that move at least 4\" with any number of characters in 1 round." },
  { first_roll: "7-9", second_roll: 9, name: "Keep the Monsters at Bay", description: "Kill an enemy character with a larger base size." },
  { first_roll: "7-9", second_roll: 10, name: "Don't Let Them Hide", description: "Kill an enemy character while they are in Cover." },

  # 1st Roll: 10
  { first_roll: "10", second_roll: 1, name: "Get to Ground", description: "Perform 3 controlled landings with any number of characters in 1 round." },
  { first_roll: "10", second_roll: 2, name: "Daredevil", description: "Have a friendly character survive a fall of at least 6\"." },
  { first_roll: "10", second_roll: 3, name: "High Dive", description: "Fall into water 3 times. This can be done with any number of characters." },
  { first_roll: "10", second_roll: 4, name: "Aquatic Attack", description: "Perform 3 Dive actions with any number of characters in 1 round." },
  { first_roll: "10", second_roll: 5, name: "Hold Your Breath", description: "Have a friendly character perform 2 Dive actions in 2 subsequent rounds." }
].each do |attrs|
  Catalog::Agenda.find_or_initialize_by(first_roll: attrs[:first_roll], second_roll: attrs[:second_roll]).update!(attrs)
end

puts "Total: #{Catalog::Agenda.count} agendas"
