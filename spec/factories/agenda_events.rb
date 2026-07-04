FactoryBot.define do
  factory :agenda_event, class: "Encounter::AgendaEvent" do
    association :game_player
    association :agenda
    action { "drawn" }
    origin { "initial" }
    turn { 1 }
  end
end
