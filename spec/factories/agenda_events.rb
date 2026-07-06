FactoryBot.define do
  factory :agenda_event, class: "Encounter::AgendaEvent" do
    association :game_player
    association :agenda
    action { "drawn" }
    origin { "initial" }
    turn { 1 }
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
#  fk_rails_...  (caused_by_event_id => agenda_events.id) ON DELETE => nullify
#  fk_rails_...  (game_player_id => game_players.id)
#
