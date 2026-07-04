require 'rails_helper'

RSpec.describe Encounter::Player, type: :model do
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

  it "only allows one deployment roll winner per game at the database level" do
    game = create(:game)
    create(:game_player, game: game, won_deployment_roll: true)
    other = build(:game_player, game: game, won_deployment_roll: true)

    expect { other.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end

# == Schema Information
#
# Table name: game_players
#
#  id                  :bigint           not null, primary key
#  agenda_ids          :json             not null
#  host                :boolean          default(FALSE), not null
#  ready               :boolean          default(FALSE), not null
#  role                :string
#  visibility          :string           default("active"), not null
#  won_deployment_roll :boolean          default(FALSE), not null
#  won_role_roll       :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  game_id             :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_game_players_on_game_id                            (game_id)
#  index_game_players_on_game_id_and_user_id                (game_id,user_id) UNIQUE
#  index_game_players_on_game_id_where_won_deployment_roll  (game_id) UNIQUE WHERE won_deployment_roll
#  index_game_players_on_game_id_where_won_role_roll        (game_id) UNIQUE WHERE won_role_roll
#  index_game_players_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
