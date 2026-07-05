require 'rails_helper'

RSpec.describe EntryStateSerializer do
  it "pairs each stat's current value with its starting value" do
    entry_state = build(:entry_state, current_life_points: 6, starting_life_points: 10)

    json = described_class.new(entry_state).as_json

    expect(json[:life_points]).to eq(current: 6, starting: 10)
  end
end
