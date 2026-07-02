class Game < ApplicationRecord
  STATUSES = %w[pending gang_selection agenda_draw deployment_rolloff deploying in_progress completed].freeze
  AGENDA_BUCKET_WEIGHTS = %w[1-3 1-3 1-3 4-6 4-6 4-6 7-9 7-9 7-9 10].freeze

  belongs_to :scenario
  belongs_to :role_roll_winner, class_name: "GamePlayer", optional: true
  belongs_to :deployment_roll_winner, class_name: "GamePlayer", optional: true

  has_many :game_players, dependent: :destroy

  enum :status, STATUSES.index_with(&:itself), default: "pending"

  validates :ducat_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :join_code, presence: true, uniqueness: true

  before_validation :generate_join_code, on: :create

  # Rolls `kind` (:role or :deployment) for `game_player`, then resolves the pair once both
  # players have rolled: ties reroll automatically (no extra client action), otherwise the
  # higher roll wins and `#{kind}_roll_winner` is set.
  def roll!(kind, game_player)
    game_player.update!("#{kind}_roll" => rand(1..6))
    resolve_roll!(kind)
  end

  # Winner's choice is assigned to `chooser`; the complementary option is auto-assigned to the
  # other player. Used for both attacker/defender and deployment zone A/B.
  def assign_paired_choice!(attribute, chooser, chosen, options)
    return false unless options.include?(chosen)

    other = game_players.find { |p| p.id != chooser.id }
    chooser.update!(attribute => chosen)
    other.update!(attribute => (options - [ chosen ]).first)
    true
  end

  def draw_agendas!(game_player)
    count = scenario.agendas.first.to_s[/\A(\d+)/, 1].to_i
    count = 3 if count.zero?
    drawn = []
    drawn << draw_one_agenda_id(drawn) while drawn.size < count
    game_player.update!(agenda_ids: drawn)
  end

  def as_json_for(viewer_game_player)
    {
      id: id,
      join_code: join_code,
      status: status,
      ducat_limit: ducat_limit,
      board_size: board_size,
      scenario: scenario.as_json_for_game,
      role_roll_winner_id: role_roll_winner_id,
      deployment_roll_winner_id: deployment_roll_winner_id,
      players: game_players.map { |gp| gp.as_json_for(viewer_game_player) }
    }
  end

  # Broadcasts to each connected player individually (not a single shared game-wide broadcast),
  # so every player's payload can stay scoped to their own private data (drawn agendas).
  def broadcast_state!
    game_players.reload.each do |gp|
      GameChannel.broadcast_to(gp, { event: "game_state", game: as_json_for(gp) })
    end
  end

  private

  def resolve_roll!(kind)
    players = game_players.reload.to_a
    return unless players.size == 2 && players.all? { |p| p.public_send("#{kind}_roll").present? }

    a, b = players
    if a.public_send("#{kind}_roll") == b.public_send("#{kind}_roll")
      players.each { |p| p.update!("#{kind}_roll" => rand(1..6)) }
      resolve_roll!(kind)
    else
      winner = players.max_by { |p| p.public_send("#{kind}_roll") }
      update!("#{kind}_roll_winner" => winner)
    end
  end

  def draw_one_agenda_id(already_drawn)
    loop do
      bucket = AGENDA_BUCKET_WEIGHTS.sample
      agenda = Agenda.where(first_roll: bucket).order(Arel.sql("RANDOM()")).first
      next if already_drawn.include?(agenda.id)
      break agenda.id
    end
  end

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
