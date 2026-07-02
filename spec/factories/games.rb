FactoryBot.define do
  factory :game do
    association :scenario
    ducat_limit { 150 }
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
