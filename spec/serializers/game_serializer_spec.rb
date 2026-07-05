require 'rails_helper'

RSpec.describe GameSerializer do
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

    small_queries = count_queries { described_class.new(small, viewer: small.game_players.first).as_json }
    large_queries = count_queries { described_class.new(large, viewer: large.game_players.first).as_json }

    expect(large_queries).to eq(small_queries)
  end
end
