class GamePlayer < ApplicationRecord
  ROLES = %w[attacker defender].freeze
  DEPLOYMENT_ZONES = %w[A B].freeze
  VISIBILITIES = %w[active archived deleted].freeze

  belongs_to :game
  belongs_to :user
  belongs_to :list, optional: true

  has_many :won_role_rolls, class_name: "Game", foreign_key: :role_roll_winner_id, dependent: :nullify, inverse_of: :role_roll_winner
  has_many :won_deployment_rolls, class_name: "Game", foreign_key: :deployment_roll_winner_id, dependent: :nullify, inverse_of: :deployment_roll_winner

  enum :visibility, VISIBILITIES.index_with(&:itself), default: "active"

  validates :user_id, uniqueness: { scope: :game_id }
  validates :role, inclusion: { in: ROLES }, allow_nil: true
  validates :deployment_zone, inclusion: { in: DEPLOYMENT_ZONES }, allow_nil: true

  def as_json_for(viewer_game_player)
    {
      id: id,
      user_id: user_id,
      username: user.username,
      host: host,
      list: list&.as_json_summary,
      role: role,
      deployment_zone: deployment_zone,
      ready: ready,
      # Drawn agendas are private — only ever revealed to the player who drew them.
      agendas: viewer_game_player&.id == id ? Agenda.where(id: agenda_ids).map { |a| { id: a.id, name: a.name, description: a.description } } : []
    }
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
