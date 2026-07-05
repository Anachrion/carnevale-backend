require 'rails_helper'

RSpec.describe Encounter::Game, type: :model do
  it "generates a unique join code on create" do
    game = create(:game)
    expect(game.join_code).to match(/\A[A-Z0-9]{6}\z/)
  end

  it "defaults to pending status" do
    expect(create(:game).status).to eq("pending")
  end

  it "is invalid without a positive ducat_limit" do
    game = build(:game, ducat_limit: 0)
    expect(game).not_to be_valid
  end

  it "defaults name to the scenario's name when not provided" do
    scenario = create(:scenario, name: "The Duel")
    game = create(:game, scenario: scenario, name: nil)
    expect(game.name).to eq("The Duel")
  end

  it "keeps an explicitly provided name" do
    game = create(:game, name: "Rivals in the Rain")
    expect(game.name).to eq("Rivals in the Rain")
  end

  describe "#assign_roll_winners!" do
    it "assigns exactly one deployment roll winner once both players have joined" do
      game = create(:game, scenario: create(:scenario, asymmetric: false))
      create_list(:game_player, 2, game: game)

      game.assign_roll_winners!

      expect(game.deployment_roll_winner).to be_present
      expect(game.game_players.count(&:won_deployment_roll?)).to eq(1)
    end

    it "only assigns a role roll winner for asymmetric scenarios" do
      symmetric = create(:game, scenario: create(:scenario, asymmetric: false))
      create_list(:game_player, 2, game: symmetric)
      symmetric.assign_roll_winners!
      expect(symmetric.role_roll_winner).to be_nil

      asymmetric = create(:game, scenario: create(:scenario, asymmetric: true))
      create_list(:game_player, 2, game: asymmetric)
      asymmetric.assign_roll_winners!
      expect(asymmetric.role_roll_winner).to be_present
    end

    it "does nothing until both players have joined" do
      game = create(:game)
      create(:game_player, game: game)

      game.assign_roll_winners!

      expect(game.deployment_roll_winner).to be_nil
    end
  end

  describe "#as_json_for" do
    def game_with_agendas(per_player:)
      game = create(:game, scenario: create(:scenario, asymmetric: false), status: "in_progress")
      2.times do
        gp = create(:game_player, game: game, user: create(:user))
        list = create(:list, owner: gp, faction: "guild", points: 100)
        create(:list_entry, list: list, entry: create(:card_reference), position: 1)
        per_player.times { |i| create(:agenda_event, game_player: gp, action: "drawn", origin: "initial", turn: i + 1) }
      end
      game
    end

    def preloaded(game)
      Encounter::Game.includes(:scenario, game_players: [ :user, :list, :agenda_events ]).find(game.id)
    end

    # B-P2-4: serializing a game read per-player list, score, and drawn/held agendas with a query
    # each. With the associations preloaded it must not issue more queries as a player's agenda
    # count grows.
    it "does not issue more queries as each player's agenda count grows" do
      small = preloaded(game_with_agendas(per_player: 1))
      large = preloaded(game_with_agendas(per_player: 5))

      small_queries = count_queries { small.as_json_for(small.game_players.first) }
      large_queries = count_queries { large.as_json_for(large.game_players.first) }

      expect(large_queries).to eq(small_queries)
    end
  end

  describe "#start!" do
    it "flips the game to in_progress once both players are ready" do
      game = create(:game, status: "deploying")
      create_list(:game_player, 2, game: game, ready: true)

      expect(game.start!).to be true
      expect(game.reload.status).to eq("in_progress")
    end

    it "does nothing until both players are ready" do
      game = create(:game, status: "deploying")
      create(:game_player, game: game, ready: true)
      create(:game_player, game: game, ready: false)

      expect(game.start!).to be false
      expect(game.reload.status).to eq("deploying")
    end

    it "does not re-run once already in_progress" do
      game = create(:game, status: "in_progress")
      create_list(:game_player, 2, game: game, ready: true)

      expect(game.start!).to be false
    end

    it "creates an entry state for each card-reference entry, snapshotting the profile's stats" do
      game = create(:game, status: "deploying")
      host, _guest = create_list(:game_player, 2, game: game, ready: true)
      profile = create(:profile, life_points: 8, will_points: 2, command_points: 1)
      list = create(:list, owner: host)
      list_entry = create(:list_entry, list: list, entry: create(:card_reference, profile: profile))

      game.start!

      entry_state = list_entry.reload.entry_state
      expect(entry_state).to be_present
      expect(entry_state.current_life_points).to eq(8)
      expect(entry_state.starting_will_points).to eq(2)
    end

    it "does not create an entry state for equipment entries" do
      game = create(:game, status: "deploying")
      host, _guest = create_list(:game_player, 2, game: game, ready: true)
      list = create(:list, owner: host)
      list_entry = create(:list_entry, list: list, entry: create(:equipment))

      game.start!

      expect(list_entry.reload.entry_state).to be_nil
    end
  end

  describe "#advance_turn!" do
    it "increments current_turn while turns remain" do
      scenario = create(:scenario, turns: 2)
      game = create(:game, scenario: scenario, status: "in_progress")

      expect { game.advance_turn! }.to change { game.current_turn }.from(1).to(2)
    end

    it "completes the game instead of exceeding the scenario's turn count" do
      scenario = create(:scenario, turns: 1)
      game = create(:game, scenario: scenario, status: "in_progress")

      game.advance_turn!

      expect(game.status).to eq("completed")
      expect(game.current_turn).to eq(1)
    end

    it "does nothing outside in_progress" do
      game = create(:game, status: "pending")

      expect(game.advance_turn!).to be false
      expect(game.reload.current_turn).to eq(1)
    end
  end
end

# == Schema Information
#
# Table name: games
#
#  id          :bigint           not null, primary key
#  board_size  :string
#  ducat_limit :integer          not null
#  join_code   :string           not null
#  name        :string           not null
#  status      :string           default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  scenario_id :bigint           not null
#
# Indexes
#
#  index_games_on_join_code    (join_code) UNIQUE
#  index_games_on_scenario_id  (scenario_id)
#
# Foreign Keys
#
#  fk_rails_...  (scenario_id => scenarios.id)
#
