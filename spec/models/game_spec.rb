require 'rails_helper'

RSpec.describe Game, type: :model do
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
end

# == Schema Information
#
# Table name: games
#
#  id                        :bigint           not null, primary key
#  board_size                :string
#  ducat_limit               :integer          not null
#  join_code                 :string           not null
#  name                      :string
#  status                    :string           default("pending"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deployment_roll_winner_id :bigint
#  role_roll_winner_id       :bigint
#  scenario_id               :bigint           not null
#
# Indexes
#
#  index_games_on_deployment_roll_winner_id  (deployment_roll_winner_id)
#  index_games_on_join_code                  (join_code) UNIQUE
#  index_games_on_role_roll_winner_id        (role_roll_winner_id)
#  index_games_on_scenario_id                (scenario_id)
#
# Foreign Keys
#
#  fk_rails_...  (deployment_roll_winner_id => game_players.id)
#  fk_rails_...  (role_roll_winner_id => game_players.id)
#  fk_rails_...  (scenario_id => scenarios.id)
#
