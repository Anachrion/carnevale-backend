require 'rails_helper'

RSpec.describe Encounter::AgendaDeck, type: :model do
  def deck_for(game)
    described_class.new(game)
  end

  describe "#draw_initial" do
    it "logs each drawn card as an initial-origin event" do
      %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) }
      scenario = create(:scenario, agendas: [ "3 scoring 1 Victory Point each." ])
      game = create(:game, scenario: scenario)
      game_player = create(:game_player, game: game)

      deck_for(game).draw_initial(game_player)

      expect(game_player.hand_agenda_ids.size).to eq(3)
      expect(game_player.agenda_events.pluck(:origin).uniq).to eq([ "initial" ])
    end

    # B-P2-9: the draw used to loop forever if the weighted buckets it sampled were all exhausted.
    # With the whole pool confined to one bucket, the sampler keeps missing the others and must
    # fall back to the remaining agendas rather than spinning — so this both terminates and draws.
    it "terminates and draws distinct agendas when the pool is confined to one bucket" do
      create_list(:agenda, 3, first_roll: "1-3")
      scenario = create(:scenario, agendas: [ "3 agendas" ])
      game = create(:game, scenario: scenario)
      game_player = create(:game_player, game: game)

      deck_for(game).draw_initial(game_player)

      drawn = game_player.agenda_events.where(action: "drawn").pluck(:agenda_id)
      expect(drawn.size).to eq(3)
      expect(drawn.uniq.size).to eq(3)
    end
  end

  describe "#draw" do
    before { %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) } }

    it "logs a single drawn event with the given origin" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      deck_for(game).draw(game_player, origin: "special_rule")

      expect(game_player.agenda_events.count).to eq(1)
      expect(game_player.agenda_events.first.origin).to eq("special_rule")
    end

    it "never draws an agenda that player has already drawn" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      5.times { deck_for(game).draw(game_player, origin: "special_rule") }

      ids = game_player.drawn_agenda_ids
      expect(ids.uniq.size).to eq(ids.size)
    end

    it "rejects origin: initial outside the initial batch draw" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)

      expect { deck_for(game).draw(game_player, origin: "initial") }.to raise_error(ArgumentError)
    end
  end

  describe "#score / #discard" do
    it "scores an agenda in hand, adding to the running score" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)
      game_player.agenda_events.create!(agenda: agenda, action: "drawn", origin: "initial", turn: 1)

      expect(deck_for(game).score(game_player, agenda.id)).to be true
      expect(game_player.hand_agenda_ids).not_to include(agenda.id)
      expect(game_player.score).to eq(1)
    end

    it "rejects scoring an agenda not in hand" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)

      expect(deck_for(game).score(game_player, agenda.id)).to be false
    end

    it "rejects discarding an agenda not in hand" do
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda)

      expect(deck_for(game).discard(game_player, agenda.id, origin: "command_point")).to be false
    end

    it "recycle: true draws a replacement card linked back to the triggering event" do
      %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) }
      game = create(:game, status: "in_progress")
      game_player = create(:game_player, game: game)
      agenda = create(:agenda, first_roll: "1-3")
      game_player.agenda_events.create!(agenda: agenda, action: "drawn", origin: "initial", turn: 1)

      deck_for(game).score(game_player, agenda.id, recycle: true)

      recycle_event = game_player.agenda_events.find_by(origin: "recycle")
      expect(recycle_event).to be_present
      expect(recycle_event.caused_by_event.action).to eq("scored")
      expect(recycle_event.caused_by_event.agenda_id).to eq(agenda.id)
    end
  end
end
