module Encounter
  class Player < ApplicationRecord
    self.table_name = "game_players"

    ROLES = %w[attacker defender].freeze
    VISIBILITIES = %w[active archived deleted].freeze

    belongs_to :game, class_name: "Encounter::Game"
    belongs_to :user
    has_one :list, as: :owner, class_name: "Gang::List", dependent: :destroy
    has_many :agenda_events, class_name: "Encounter::AgendaEvent", foreign_key: "game_player_id", dependent: :destroy

    enum :visibility, VISIBILITIES.index_with(&:itself), default: "active"

    validates :user_id, uniqueness: { scope: :game_id }
    validates :role, inclusion: { in: ROLES }, allow_nil: true

    RESOLVED_ACTIONS = %w[scored discarded].freeze

    # These filter the agenda_events collection in Ruby rather than issuing a WHERE per call, so a
    # preloaded association (e.g. the games index, B-P2-4) resolves them with no extra query; an
    # unloaded one loads the (small, per-player) set once and reuses it.
    def drawn_agenda_ids
      agenda_events.select { |e| e.action == "drawn" }.map(&:agenda_id)
    end

    def resolved_agenda_ids
      agenda_events.select { |e| RESOLVED_ACTIONS.include?(e.action) }.map(&:agenda_id)
    end

    # Agendas currently held: drawn over the course of the game, minus whichever have since
    # been scored or discarded (an agenda never returns to hand once resolved).
    def hand_agenda_ids
      drawn_agenda_ids - resolved_agenda_ids
    end

    # Every agenda scores a flat 1 Victory Point, so the scored count is the score.
    def score
      agenda_events.count { |e| e.action == "scored" }
    end
  end
end

# == Schema Information
#
# Table name: game_players
#
#  id                  :bigint           not null, primary key
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
