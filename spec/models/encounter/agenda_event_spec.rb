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
