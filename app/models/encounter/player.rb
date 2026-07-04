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

    def drawn_agenda_ids
      agenda_events.where(action: "drawn").pluck(:agenda_id)
    end

    def resolved_agenda_ids
      agenda_events.where(action: %w[scored discarded]).pluck(:agenda_id)
    end

    # Agendas currently held: drawn over the course of the game, minus whichever have since
    # been scored or discarded (an agenda never returns to hand once resolved).
    def hand_agenda_ids
      drawn_agenda_ids - resolved_agenda_ids
    end

    # Every agenda scores a flat 1 Victory Point, so the scored count is the score.
    def score
      agenda_events.where(action: "scored").count
    end

    def as_json_for(viewer_game_player)
      viewing_self = viewer_game_player&.id == id

      {
        id: id,
        user_id: user_id,
        username: user.username,
        host: host,
        list: list&.as_json_summary,
        role: role,
        ready: ready,
        won_role_roll: won_role_roll,
        won_deployment_roll: won_deployment_roll,
        score: score,
        # Drawn agendas and their history are private — only ever revealed to the player who drew them.
        agendas: viewing_self ? Catalog::Agenda.where(id: hand_agenda_ids).map { |a| { id: a.id, name: a.name, description: a.description } } : [],
        agenda_history: viewing_self ? agenda_history_json : []
      }
    end

    private

    def agenda_history_json
      agenda_events.includes(:agenda).order(:turn, :id).map do |event|
        {
          turn: event.turn,
          action: event.action,
          origin: event.origin,
          caused_by_event_id: event.caused_by_event_id,
          agenda: { id: event.agenda.id, name: event.agenda.name }
        }
      end
    end
  end
end
