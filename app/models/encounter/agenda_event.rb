module Encounter
  class AgendaEvent < ApplicationRecord
    ACTIONS = %w[drawn scored discarded].freeze
    ORIGINS_BY_ACTION = {
      "drawn" => %w[initial special_rule command_point recycle],
      "discarded" => %w[special_rule command_point],
      "scored" => []
    }.freeze

    belongs_to :game_player, class_name: "Encounter::Player"
    belongs_to :agenda, class_name: "Catalog::Agenda"
    belongs_to :caused_by_event, class_name: "Encounter::AgendaEvent", optional: true

    # `action` uses inclusion rather than an `enum`: the enum-generated scopes/predicates aren't
    # needed here, and inclusion keeps a bad value a validation error consistent with `origin` and
    # the other agenda-event checks below (see the same note on Player#role).
    validates :action, inclusion: { in: ACTIONS }
    validates :turn, presence: true, numericality: { only_integer: true, greater_than: 0 }
    # Mirror the DB's (game_player_id, agenda_id, action) UNIQUE index at the model level so a
    # duplicate surfaces as a validation error instead of a raw RecordNotUnique (500).
    validates :agenda_id, uniqueness: { scope: %i[game_player_id action] }
    validate :origin_matches_action
    validate :caused_by_event_only_for_recycle

    private

    def origin_matches_action
      return unless ACTIONS.include?(action)

      allowed = ORIGINS_BY_ACTION.fetch(action)
      if allowed.empty?
        errors.add(:origin, "must be blank for #{action} events") if origin.present?
      elsif origin.blank?
        errors.add(:origin, "is required for #{action} events")
      elsif !allowed.include?(origin)
        errors.add(:origin, "must be one of #{allowed.join(', ')} for #{action} events")
      end
    end

    def caused_by_event_only_for_recycle
      if origin == "recycle"
        errors.add(:caused_by_event, "is required when origin is recycle") if caused_by_event_id.blank?
      elsif caused_by_event_id.present?
        errors.add(:caused_by_event, "is only allowed when origin is recycle")
      end
    end
  end
end

# == Schema Information
#
# Table name: agenda_events
#
#  id                 :bigint           not null, primary key
#  action             :string           not null
#  origin             :string
#  turn               :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  agenda_id          :bigint           not null
#  caused_by_event_id :bigint
#  game_player_id     :bigint           not null
#
# Indexes
#
#  index_agenda_events_on_agenda_id             (agenda_id)
#  index_agenda_events_on_caused_by_event_id    (caused_by_event_id)
#  index_agenda_events_on_game_player_id        (game_player_id)
#  index_agenda_events_on_player_agenda_action  (game_player_id,agenda_id,action) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (agenda_id => agendas.id)
#  fk_rails_...  (caused_by_event_id => agenda_events.id)
#  fk_rails_...  (game_player_id => game_players.id)
#
