# ── Scenarios ───────────────────────────────────────────────────────────────────

[
  {
    name: "Gang War",
    ducats: 150,
    setup: "3'x3' board.",
    primary_objective: "Each friendly character on the board at the end of the game scores 1 Victory Point.",
    agendas: [
      "3 scoring 1 Victory Point each.",
      "Double."
    ],
    agenda_count: 3,
    agenda_rules: [ "double" ],
    special_rules: [
      "Each player sets up 1 gondola anywhere on the board in water when setting up scenery."
    ],
    duration: "5 rounds.",
    turns: 5,
    deployment_zones: [
      "Up to 8\" away from opposite board edges.",
      "2 Players shown in blue, 3-4 players shown in red."
    ]
  },
  {
    name: "Secure Arms",
    ducats: 100,
    setup: "3'x3' board.",
    primary_objective: "6 Objectives, worth 2 Victory Points, shown in green (as examples).",
    agendas: [
      "5 scoring 1 Victory Point each.",
      "Secondary."
    ],
    agenda_count: 5,
    agenda_rules: [ "secondary" ],
    special_rules: [
      "Any character within 3\" of an Objective gains the Expert Offence (2) and Expert Marksman (2) special rules."
    ],
    duration: "5 rounds.",
    turns: 5,
    deployment_zones: [
      "Up to 8\" away from opposite board edges and 12\" away from side board edges.",
      "2 Players shown in blue, 3-4 players shown in red."
    ]
  },
  {
    name: "Acquisition",
    ducats: 75,
    setup: "2'x2' board.",
    primary_objective: "2 Mobile Objectives, worth 2 Victory Points, setup along the centre line of the board, shown in green (as examples). Each Objective instead scores 3 Victory Points to a gang if it's being carried by a friendly character at the end of the game.",
    agendas: [
      "3 scoring 1 Victory Point each.",
      "Secret, Cycle, Double."
    ],
    agenda_count: 3,
    agenda_rules: [ "secret", "cycle", "double" ],
    special_rules: [
      "When choosing gangs, players do not have to include a character with the Leader keyword."
    ],
    duration: "5 rounds.",
    turns: 5,
    deployment_zones: [
      "Up to 8\" away from opposite corners.",
      "2 Players shown in blue, 3-4 players shown in red."
    ]
  },
  {
    name: "Take What is Theirs",
    ducats: 150,
    setup: "3'x3' board.",
    primary_objective: "1 Claimable Mobile Objective for each player, setup 12\" diagonally away from the Deployment Zone corner, shown in green. Each objective is automatically claimed for its controlling gang at the start of the game. Each Objective scores 3 Victory Points to a gang if it is within 12\" of their Deployment Zone corner at the end of the game. Gangs can reclaim any Objectives except for the one they controlled at the start of the game. Gangs cannot pick up their own Objective until it has been claimed by another gang.",
    agendas: [
      "3 scoring 1 Victory Point each.",
      "Cycle."
    ],
    agenda_count: 3,
    agenda_rules: [ "cycle" ],
    special_rules: [
      "Every friendly character gains the Brave special rule if they are within line of sight of a friendly character carrying an Objective."
    ],
    duration: "8 rounds.",
    turns: 8,
    deployment_zones: [
      "Up to 12\" away from opposite corners.",
      "2 Players shown in blue, 3-4 players shown in red."
    ]
  },
  {
    name: "Street Fight",
    ducats: 100,
    asymmetric: true,
    setup: "2'x4' board. Defender sets up all terrain. 1 bridge, placed in the centre of the board leading in the same way as the long board edge, shown in green.",
    primary_objective: "Every Attacking character to touch the opposite short board edge is removed from play and scores 1 Victory Point. Every Attacking character killed scores 1 Victory Point to the gang that killed them.",
    agendas: [
      "3 scoring 1 Victory Point each."
    ],
    agenda_count: 3,
    agenda_rules: [],
    special_rules: [
      "Defending players choose one friendly character in each of their gangs with Command Points to gain 3 additional Command Points at the start of the game."
    ],
    duration: "7 rounds.",
    turns: 7,
    deployment_zones: [
      "Attacker: up to 6\" away from one short board edge, shown in blue. If there is more than 1 Attacker, divide the space equally in 2, shown in dark blue.",
      "Defender: up to 24\" from the opposite short board edge, shown in red. If there is more than 1 Defender, divide the space equally in 2, shown in dark red."
    ]
  }
].each do |attrs|
  Catalog::Scenario.find_or_create_by!(name: attrs[:name]).update!(attrs)
end

puts "Total: #{Catalog::Scenario.count} scenarios"
