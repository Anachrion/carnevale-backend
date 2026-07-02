class Game < ApplicationRecord
  STATUSES = %w[pending gang_selection agenda_draw deployment_rolloff deploying in_progress completed].freeze

  belongs_to :scenario
  belongs_to :role_roll_winner, class_name: "GamePlayer", optional: true
  belongs_to :deployment_roll_winner, class_name: "GamePlayer", optional: true

  has_many :game_players, dependent: :destroy

  enum :status, STATUSES.index_with(&:itself), default: "pending"

  validates :ducat_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :join_code, presence: true, uniqueness: true

  before_validation :generate_join_code, on: :create

  private

  def generate_join_code
    self.join_code ||= loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Game.exists?(join_code: code)
    end
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
