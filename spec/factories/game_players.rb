FactoryBot.define do
  factory :game_player do
    association :game
    association :user
    host { false }
  end
end

# == Schema Information
#
# Table name: game_players
#
#  id              :bigint           not null, primary key
#  agenda_ids      :json             not null
#  deployment_zone :string
#  host            :boolean          default(FALSE), not null
#  ready           :boolean          default(FALSE), not null
#  role            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_id         :bigint           not null
#  list_id         :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_game_players_on_game_id              (game_id)
#  index_game_players_on_game_id_and_user_id  (game_id,user_id) UNIQUE
#  index_game_players_on_list_id              (list_id)
#  index_game_players_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
