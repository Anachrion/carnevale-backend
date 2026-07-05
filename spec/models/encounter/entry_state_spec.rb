require 'rails_helper'

RSpec.describe Encounter::EntryState, type: :model do
  describe "validations" do
    it "is valid with the default factory" do
      expect(build(:entry_state)).to be_valid
    end

    it "rejects a second entry state for the same list entry" do
      list_entry = create(:list_entry)
      create(:entry_state, list_entry: list_entry)

      expect(build(:entry_state, list_entry: list_entry)).not_to be_valid
    end

    it "rejects negative current values" do
      expect(build(:entry_state, current_life_points: -1)).not_to be_valid
    end

    it "rejects unknown counter keys" do
      entry_state = build(:entry_state, counters: { "invincible" => true })
      expect(entry_state).not_to be_valid
    end

    it "rejects a non-boolean value for a boolean counter" do
      entry_state = build(:entry_state, counters: { "stunned" => "yes", "hidden" => false, "guarding" => false, "carrying_objective" => false, "underwater_counters" => 0 })
      expect(entry_state).not_to be_valid
    end

    it "rejects underwater_counters outside 0..2" do
      entry_state = build(:entry_state, counters: { "stunned" => false, "hidden" => false, "guarding" => false, "carrying_objective" => false, "underwater_counters" => 3 })
      expect(entry_state).not_to be_valid
    end
  end

  describe ".create_for!" do
    it "snapshots the entry's profile stats as both current and starting values" do
      profile = create(:profile, life_points: 12, will_points: 4, command_points: 2)
      list_entry = create(:list_entry, entry: create(:card_reference, profile: profile))

      entry_state = Encounter::EntryState.create_for!(list_entry)

      expect(entry_state.current_life_points).to eq(12)
      expect(entry_state.starting_life_points).to eq(12)
      expect(entry_state.current_will_points).to eq(4)
      expect(entry_state.starting_will_points).to eq(4)
      expect(entry_state.current_command_points).to eq(2)
      expect(entry_state.starting_command_points).to eq(2)
    end

    it "defaults every counter to its resting state" do
      list_entry = create(:list_entry)

      entry_state = Encounter::EntryState.create_for!(list_entry)

      expect(entry_state.stunned?).to be false
      expect(entry_state.hidden?).to be false
      expect(entry_state.guarding?).to be false
      expect(entry_state.carrying_objective?).to be false
      expect(entry_state.underwater_counters).to eq(0)
    end
  end

  describe "#as_json_for_display" do
    it "pairs each stat's current value with its starting value" do
      entry_state = build(:entry_state, current_life_points: 6, starting_life_points: 10)

      json = entry_state.as_json_for_display

      expect(json[:life_points]).to eq(current: 6, starting: 10)
    end
  end
end

# == Schema Information
#
# Table name: entry_states
#
#  id                      :bigint           not null, primary key
#  counters                :json             not null
#  current_command_points  :integer          not null
#  current_life_points     :integer          not null
#  current_will_points     :integer          not null
#  starting_command_points :integer          not null
#  starting_life_points    :integer          not null
#  starting_will_points    :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  list_entry_id           :bigint           not null
#
# Indexes
#
#  index_entry_states_on_list_entry_id  (list_entry_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#
