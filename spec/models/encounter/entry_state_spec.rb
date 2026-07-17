require 'rails_helper'

RSpec.describe Encounter::EntryState, type: :model do
  # A full, valid counters hash with the given keys overridden — so a spec that cares about one
  # counter doesn't fail the shape validation on the others.
  def base_counters(overrides = {})
    Encounter::EntryState::DEFAULT_COUNTERS.merge(overrides)
  end

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

    it "rejects a non-positive-integer activated_on_turn" do
      expect(build(:entry_state, counters: base_counters("activated_on_turn" => 0))).not_to be_valid
      expect(build(:entry_state, counters: base_counters("activated_on_turn" => true))).not_to be_valid
    end

    it "accepts a state whose counters predate activation tracking" do
      # Entry states created before the key existed omit it entirely — they must stay valid so an
      # in-flight game doesn't need a backfill.
      legacy = base_counters.except("activated_on_turn")
      expect(build(:entry_state, counters: legacy)).to be_valid
    end

    it "rejects a spell_casts key not shaped like spell:<id> or granted:<id>" do
      expect(build(:entry_state, spell_casts: { "spell:abc" => 1 })).not_to be_valid
      expect(build(:entry_state, spell_casts: { "cantrip:1" => 1 })).not_to be_valid
      expect(build(:entry_state, spell_casts: { "spell:1" => 1 })).to be_valid
      expect(build(:entry_state, spell_casts: { "granted:7" => 1 })).to be_valid
    end

    it "rejects a non-positive-integer spell_casts turn" do
      expect(build(:entry_state, spell_casts: { "spell:1" => 0 })).not_to be_valid
      expect(build(:entry_state, spell_casts: { "spell:1" => true })).not_to be_valid
      expect(build(:entry_state, spell_casts: { "spell:1" => nil })).not_to be_valid
    end
  end

  describe "#activated?" do
    it "is true only on the turn the model was stamped with" do
      entry_state = build(:entry_state, counters: base_counters("activated_on_turn" => 3))

      expect(entry_state.activated?(3)).to be true
      # The reset is implicit: a new turn matches nothing, so the whole gang reads as un-activated.
      expect(entry_state.activated?(4)).to be false
      # ...and rewinding back to turn 3 restores it, rather than having cleared it.
      expect(entry_state.activated?(3)).to be true
    end

    it "is false when never activated, or with no turn to compare against" do
      expect(build(:entry_state).activated?(1)).to be false
      expect(build(:entry_state, counters: base_counters("activated_on_turn" => 3)).activated?(nil)).to be false
    end
  end

  describe "#dead?" do
    it "is true exactly when the model has lost its last life point" do
      expect(build(:entry_state, current_life_points: 1)).not_to be_dead
      expect(build(:entry_state, current_life_points: 0)).to be_dead
    end

    # Derived, not stored: the only way to kill a model is to take its HP to 0, and the only way to
    # revive it is to give HP back — so the flag can never contradict the HP shown beside it.
    it "follows current HP, with no separate state to fall out of step" do
      entry_state = build(:entry_state, current_life_points: 3)

      entry_state.current_life_points = 0
      expect(entry_state).to be_dead

      entry_state.current_life_points = 2
      expect(entry_state).not_to be_dead
    end
  end

  describe "#set_activated" do
    it "stamps the given turn, and clears it back to nil" do
      entry_state = build(:entry_state)

      entry_state.set_activated(true, turn: 2)
      expect(entry_state.counters["activated_on_turn"]).to eq(2)

      entry_state.set_activated(false, turn: 2)
      expect(entry_state.counters["activated_on_turn"]).to be_nil
    end

    it "leaves the other counters untouched" do
      entry_state = build(:entry_state, counters: base_counters("stunned" => true, "underwater_counters" => 2))

      entry_state.set_activated(true, turn: 1)

      expect(entry_state).to be_valid
      expect(entry_state.stunned?).to be true
      expect(entry_state.underwater_counters).to eq(2)
    end
  end

  describe "#spell_cast?" do
    it "is true only on the turn it was cast, for a resets_each_round pool/grant" do
      entry_state = build(:entry_state, spell_casts: { "spell:1" => 3 })

      expect(entry_state.spell_cast?("spell:1", resets_each_round: true, current_turn: 3)).to be true
      # The reset is implicit, same as activated_on_turn: a new turn matches nothing.
      expect(entry_state.spell_cast?("spell:1", resets_each_round: true, current_turn: 4)).to be false
      # ...and rewinding back to turn 3 restores it.
      expect(entry_state.spell_cast?("spell:1", resets_each_round: true, current_turn: 3)).to be true
    end

    it "stays cast on any later turn once stored, for a resets_each_round: false pool (Adventuring Noble)" do
      entry_state = build(:entry_state, spell_casts: { "spell:1" => 2 })

      expect(entry_state.spell_cast?("spell:1", resets_each_round: false, current_turn: 2)).to be true
      expect(entry_state.spell_cast?("spell:1", resets_each_round: false, current_turn: 3)).to be true
    end

    it "is false when never cast" do
      entry_state = build(:entry_state)

      expect(entry_state.spell_cast?("spell:1", resets_each_round: true, current_turn: 1)).to be false
      expect(entry_state.spell_cast?("spell:1", resets_each_round: false, current_turn: 1)).to be false
    end
  end

  describe "#set_spell_cast" do
    it "stamps the given turn, and clears it back out" do
      entry_state = build(:entry_state)

      entry_state.set_spell_cast("spell:1", cast: true, turn: 2)
      expect(entry_state.spell_casts["spell:1"]).to eq(2)

      entry_state.set_spell_cast("spell:1", cast: false, turn: 2)
      expect(entry_state.spell_casts).not_to have_key("spell:1")
    end

    it "clears a resets_each_round: false spell manually too, so a misclick is always correctable" do
      entry_state = build(:entry_state, spell_casts: { "spell:1" => 2 })

      entry_state.set_spell_cast("spell:1", cast: false, turn: 5)

      expect(entry_state.spell_cast?("spell:1", resets_each_round: false, current_turn: 5)).to be false
    end

    it "leaves other spells' cast state untouched" do
      entry_state = build(:entry_state, spell_casts: { "granted:7" => 1 })

      entry_state.set_spell_cast("spell:1", cast: true, turn: 1)

      expect(entry_state).to be_valid
      expect(entry_state.spell_casts["granted:7"]).to eq(1)
      expect(entry_state.spell_casts["spell:1"]).to eq(1)
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
      expect(entry_state.activated?(1)).to be false
      expect(entry_state.spell_cast?("spell:1", resets_each_round: true, current_turn: 1)).to be false
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
#  spell_casts             :json             not null
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
