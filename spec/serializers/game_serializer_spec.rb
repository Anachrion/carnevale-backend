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
    Encounter::Game.includes(:scenario, game_players: [ :user, :list, { agenda_events: :agenda } ]).find(game.id)
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

  # A-3: the version has to ride on every Game the API returns, not just on broadcasts. The widest
  # ordering hazard is a mutation response — serialized before the opponent's change committed —
  # landing after the broadcast that carried it, and the client can only order the two if both
  # carry a version. Every REST response goes through this serializer, so covering it here covers
  # all of them.
  it "stamps the game's state_version" do
    game = create(:game, state_version: 7)
    gp = create(:game_player, game: game)

    expect(described_class.new(game, viewer: gp).as_json[:state_version]).to eq(7)
  end
end
