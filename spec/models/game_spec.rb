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
