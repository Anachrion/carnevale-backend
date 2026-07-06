require 'rails_helper'

RSpec.describe Encounter::AgendaEvent, type: :model do
  it "requires an origin for drawn events" do
    expect(build(:agenda_event, action: "drawn", origin: nil)).not_to be_valid
  end

  it "requires an origin for discarded events" do
    expect(build(:agenda_event, action: "discarded", origin: nil)).not_to be_valid
  end

  it "rejects initial as an origin for discarded events" do
    expect(build(:agenda_event, action: "discarded", origin: "initial")).not_to be_valid
  end

  it "accepts unachievable as an origin for discarded events (the pre-game mulligan)" do
    expect(build(:agenda_event, action: "discarded", origin: "unachievable")).to be_valid
  end

  it "requires origin to be blank for scored events" do
    expect(build(:agenda_event, action: "scored", origin: "special_rule")).not_to be_valid
  end

  it "is valid with no origin for scored events" do
    expect(build(:agenda_event, action: "scored", origin: nil)).to be_valid
  end

  it "requires caused_by_event when origin is recycle" do
    expect(build(:agenda_event, action: "drawn", origin: "recycle", caused_by_event: nil)).not_to be_valid
  end

  it "forbids caused_by_event unless origin is recycle" do
    other = create(:agenda_event, action: "scored", origin: nil)
    expect(build(:agenda_event, action: "drawn", origin: "special_rule", caused_by_event: other)).not_to be_valid
  end

  it "is valid with caused_by_event when origin is recycle" do
    other = create(:agenda_event, action: "scored", origin: nil)
    expect(build(:agenda_event, action: "drawn", origin: "recycle", caused_by_event: other)).to be_valid
  end

  it "enforces one event per action per agenda per player at the database level" do
    game_player = create(:game_player)
    agenda = create(:agenda)
    create(:agenda_event, game_player: game_player, agenda: agenda, action: "drawn", origin: "initial")
    dup = build(:agenda_event, game_player: game_player, agenda: agenda, action: "drawn", origin: "special_rule")

    expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
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
