module Encounter
  class Game < ApplicationRecord
    STATUSES = %w[pending gang_selection agenda_draw deploying in_progress completed].freeze

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

    # The setup window in which a player may mulligan an impossible/duplicated agenda (discard +
    # redraw): after the initial draw and up until the game goes live. The status auto-advances from
    # agenda_draw to deploying once both players have drawn, so both count as the same window.
    def mulligan_window?
      agenda_draw? || deploying?
    end

    # The agenda-deck subsystem (initial/in-play draws, scoring, discarding). Lives in its own
    # service object rather than on the model (B-P2-7).
    def agenda_deck
      @agenda_deck ||= AgendaDeck.new(self)
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

    # Completion is derived from the players' per-player `finished` flags rather than driven by the
    # turn counter: the game is `completed` only once both players have ended it, and reverts to
    # `in_progress` the moment either undoes (so one player finishing never ends it for the other).
    # Called after any finish/unfinish; a no-op outside the in-play phases.
    def refresh_completion!
      return unless in_progress? || completed?

      all_finished = game_players.reload.all?(&:finished?)
      if all_finished && !completed?
        update!(status: "completed")
      elsif !all_finished && completed?
        update!(status: "in_progress")
      end
    end

    private

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
#  id          :bigint           not null, primary key
#  board_size  :string
#  ducat_limit :integer          not null
#  join_code   :string           not null
#  name        :string           not null
#  status      :string           default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  scenario_id :bigint           not null
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
