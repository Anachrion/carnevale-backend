require 'rails_helper'

RSpec.describe GamePlayer, type: :model do
  it "rejects a user joining the same game twice" do
    game = create(:game)
    user = create(:user)
    create(:game_player, game: game, user: user)
    dup = build(:game_player, game: game, user: user)
    expect(dup).not_to be_valid
  end

  it "rejects a role outside attacker/defender" do
    game_player = build(:game_player, role: "referee")
    expect(game_player).not_to be_valid
  end

  it "rejects a deployment_zone outside A/B" do
    game_player = build(:game_player, deployment_zone: "north")
    expect(game_player).not_to be_valid
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
#  visibility      :string           default("active"), not null
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
