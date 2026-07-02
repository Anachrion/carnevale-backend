class GamePlayer < ApplicationRecord
  ROLES = %w[attacker defender].freeze
  DEPLOYMENT_ZONES = %w[A B].freeze

  belongs_to :game
  belongs_to :user
  belongs_to :list, optional: true

  has_many :won_role_rolls, class_name: "Game", foreign_key: :role_roll_winner_id, dependent: :nullify, inverse_of: :role_roll_winner
  has_many :won_deployment_rolls, class_name: "Game", foreign_key: :deployment_roll_winner_id, dependent: :nullify, inverse_of: :deployment_roll_winner

  validates :user_id, uniqueness: { scope: :game_id }
  validates :role, inclusion: { in: ROLES }, allow_nil: true
  validates :deployment_zone, inclusion: { in: DEPLOYMENT_ZONES }, allow_nil: true
end

# == Schema Information
#
# Table name: game_players
#
#  id              :bigint           not null, primary key
#  agenda_ids      :json             not null
#  deployment_roll :integer
#  deployment_zone :string
#  host            :boolean          default(FALSE), not null
#  ready           :boolean          default(FALSE), not null
#  role            :string
#  role_roll       :integer
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
