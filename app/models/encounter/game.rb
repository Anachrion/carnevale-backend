module Encounter
  class Game < ApplicationRecord
    STATUSES = %w[pending gang_selection agenda_draw deploying in_progress completed].freeze
    AGENDA_BUCKET_WEIGHTS = %w[1-3 1-3 1-3 4-6 4-6 4-6 7-9 7-9 7-9 10].freeze

    belongs_to :scenario, class_name: "Catalog::Scenario"

    has_many :game_players, class_name: "Encounter::Player", dependent: :destroy

    enum :status, STATUSES.index_with(&:itself), default: "pending"

    validates :ducat_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :join_code, presence: true, uniqueness: true
    validates :name, presence: true

    before_validation :generate_join_code, on: :create
    before_validation :default_name_to_scenario, on: :create

    # Picks the roll-off winners as soon as both players are in the game, so nothing depends on
    # a client action: deployment_roll_winner is always assigned (shown for reference; the
    # deployment zone itself is chosen at the table, not in-app), role_roll_winner only for
    # asymmetric scenarios (where it matters).
    def assign_roll_winners!
      players = game_players.reload.to_a
      return unless players.size == 2

      players.sample.update!(won_role_roll: true) if scenario.asymmetric?
      players.sample.update!(won_deployment_roll: true)
    end

    def role_roll_winner
      game_players.find(&:won_role_roll?)
    end

    def deployment_roll_winner
      game_players.find(&:won_deployment_roll?)
    end

    # Winner's choice is assigned to `chooser`; the complementary option is auto-assigned to the
    # other player. Used for the attacker/defender role pick.
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
      drawn.each do |agenda_id|
        game_player.agenda_events.create!(agenda_id: agenda_id, action: "drawn", origin: "initial", turn: current_turn)
      end
    end

    # Single card draw during play (as opposed to the initial batch above), e.g. granted by a
    # special rule, a command point ability, or as the replacement half of a "Cycle" scenario
    # rule (origin: "recycle", caused_by_event: the score/discard that triggered it).
    def draw_agenda!(game_player, origin:, caused_by_event: nil)
      raise ArgumentError, "origin must not be \"initial\" outside the initial draw" if origin == "initial"

      already_drawn = game_player.drawn_agenda_ids
      agenda_id = draw_one_agenda_id(already_drawn)
      game_player.agenda_events.create!(agenda_id: agenda_id, action: "drawn", origin: origin, caused_by_event: caused_by_event, turn: current_turn)
    end

    def score_agenda!(game_player, agenda_id, recycle: false)
      return false unless game_player.hand_agenda_ids.include?(agenda_id)

      event = game_player.agenda_events.create!(agenda_id: agenda_id, action: "scored", turn: current_turn)
      draw_agenda!(game_player, origin: "recycle", caused_by_event: event) if recycle
      true
    end

    def discard_agenda!(game_player, agenda_id, origin:, recycle: false)
      return false unless game_player.hand_agenda_ids.include?(agenda_id)

      event = game_player.agenda_events.create!(agenda_id: agenda_id, action: "discarded", origin: origin, turn: current_turn)
      draw_agenda!(game_player, origin: "recycle", caused_by_event: event) if recycle
      true
    end

    # Called once both players are ready on the deployment screen — flips the game live and
    # snapshots each model's HP/WP/CP into an Encounter::EntryState. Guarded by the status check
    # so a repeated "ready" call (e.g. a duplicate request) doesn't recreate entry states.
    def start!
      return false if in_progress? || completed?
      return false unless game_players.reload.all?(&:ready)

      transaction do
        update!(status: "in_progress")
        create_entry_states!
      end
      true
    end

    # Either player can advance the shared turn counter — like the roll winners and role pick,
    # this app tracks the physical game rather than refereeing whose turn it is to act.
    def advance_turn!
      return false unless in_progress?

      if current_turn >= scenario.turns
        update!(status: "completed")
      else
        update!(current_turn: current_turn + 1)
      end
      true
    end

    def as_json_for(viewer_game_player)
      {
        id: id,
        name: name,
        join_code: join_code,
        status: status,
        ducat_limit: ducat_limit,
        board_size: board_size,
        current_turn: current_turn,
        scenario: scenario.as_json_for_game,
        viewer_visibility: viewer_game_player&.visibility,
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

    def draw_one_agenda_id(already_drawn)
      loop do
        bucket = AGENDA_BUCKET_WEIGHTS.sample
        # Sample in Ruby rather than `ORDER BY RANDOM() LIMIT 1`: identical SQL text for a
        # repeated bucket gets served from the per-request query cache, which would return the
        # same row every time and could spin forever once that row is already drawn.
        candidates = Catalog::Agenda.where(first_roll: bucket).pluck(:id) - already_drawn
        next if candidates.empty?
        break candidates.sample
      end
    end

    # Equipment entries have no profile (no HP/WP/CP), so only card-reference entries — i.e.
    # actual models — get an entry state.
    def create_entry_states!
      game_players.each do |gp|
        next unless gp.list

        # Filtered to card references, so preloading the nested profile is safe (no Equipment in
        # the set) and spares create_for! a profile lookup per model (B-P2-1).
        entries = gp.list.list_entries.where(entry_type: "Catalog::CardReference").includes(entry: :profile)
        entries.each { |list_entry| Encounter::EntryState.create_for!(list_entry) }
      end
    end

    def generate_join_code
      self.join_code ||= loop do
        code = SecureRandom.alphanumeric(6).upcase
        break code unless Game.exists?(join_code: code)
      end
    end

    def default_name_to_scenario
      self.name = scenario.name if name.blank? && scenario
    end
  end
end

# == Schema Information
#
# Table name: games
#
#  id           :bigint           not null, primary key
#  board_size   :string
#  current_turn :integer          default(1), not null
#  ducat_limit  :integer          not null
#  join_code    :string           not null
#  name         :string           not null
#  status       :string           default("pending"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  scenario_id  :bigint           not null
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
