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

  describe "#draw_agendas!" do
    it "logs each drawn card as an initial-origin event" do
      %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) }
      scenario = create(:scenario, agendas: [ "3 scoring 1 Victory Point each." ])
      game = create(:game, scenario: scenario)
      game_player = create(:game_player, game: game)

      game.draw_agendas!(game_player)

      expect(game_player.hand_agenda_ids.size).to eq(3)
      expect(game_player.agenda_events.pluck(:origin).uniq).to eq([ "initial" ])
    end
  end

  describe "#draw_agenda!" do
    before { %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) } }

    it "logs a single drawn event with the given origin" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      game.draw_agenda!(game_player, origin: "special_rule")

      expect(game_player.agenda_events.count).to eq(1)
      expect(game_player.agenda_events.first.origin).to eq("special_rule")
    end

    it "never draws an agenda that player has already drawn" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      5.times { game.draw_agenda!(game_player, origin: "special_rule") }

      ids = game_player.drawn_agenda_ids
      expect(ids.uniq.size).to eq(ids.size)
    end

    it "rejects origin: initial outside the initial batch draw" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      expect { game.draw_agenda!(game_player, origin: "initial") }.to raise_error(ArgumentError)
    end
  end

  describe "#score_agenda! / #discard_agenda!" do
    it "scores an agenda in hand, adding to the running score" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)
      game_player.agenda_events.create!(agenda: agenda, action: "drawn", origin: "initial", turn: 1)

      expect(game.score_agenda!(game_player, agenda.id)).to be true
      expect(game_player.hand_agenda_ids).not_to include(agenda.id)
      expect(game_player.score).to eq(1)
    end

    it "rejects scoring an agenda not in hand" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)

      expect(game.score_agenda!(game_player, agenda.id)).to be false
    end

    it "rejects discarding an agenda not in hand" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)

      expect(game.discard_agenda!(game_player, agenda.id, origin: "command_point")).to be false
    end

    it "recycle: true draws a replacement card linked back to the triggering event" do
      %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) }
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda, first_roll: "1-3")
      game_player.agenda_events.create!(agenda: agenda, action: "drawn", origin: "initial", turn: 1)

      game.score_agenda!(game_player, agenda.id, recycle: true)

      recycle_event = game_player.agenda_events.find_by(origin: "recycle")
      expect(recycle_event).to be_present
      expect(recycle_event.caused_by_event.action).to eq("scored")
      expect(recycle_event.caused_by_event.agenda_id).to eq(agenda.id)
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
