require 'rails_helper'

RSpec.describe Gang::Entry, type: :model do
  describe "#resolved_pools" do
    it "returns nothing for a non-Mage profile" do
      entry = create(:list_entry, entry: create(:reference))

      expect(entry.resolved_pools).to eq([])
    end

    it "resolves a standard pool from the model's own picks" do
      profile = create(:profile, abilities: ["Mage (2)"], keywords: ["Discipline (Wild Magic)"])
      entry = create(:list_entry, entry: create(:reference, profile: profile))
      pool = profile.profile_spell_pools.first
      spell = create(:spell, discipline: :wild_magic)
      entry.entry_pool_disciplines.create!(pool: pool, discipline: "wild_magic")
      entry.entry_spells.create!(pool: pool, spell: spell)

      resolved = entry.resolved_pools.first

      expect(resolved[:of]).to eq(1)
      expect(resolved[:eligible_disciplines]).to eq(["wild_magic"])
      expect(resolved[:slot_count]).to eq(2)
      expect(resolved[:chosen_disciplines]).to eq(["wild_magic"])
      expect(resolved[:spells]).to eq([spell])
    end

    it "derives a mentor_derived pool's shape from the mentor's own first pool, keeping this model's own picks" do
      mentor_profile = create(:profile, abilities: ["Mage (2)"], keywords: ["Discipline (Wild Magic, Divinity)"])
      mentor_entry = create(:list_entry, entry: create(:reference, profile: mentor_profile))

      apprentice_profile = create(:profile)
      apprentice_profile.replace_spell_pools!([ {
        of: 1, slot_count: 0, mentor_derived: true, grants_cantrip: true, disciplines: []
      } ])
      apprentice_entry = create(:list_entry, list: mentor_entry.list, entry: create(:reference, profile: apprentice_profile),
                                 mentored_by_entry: mentor_entry)
      pool = apprentice_profile.profile_spell_pools.first
      spell = create(:spell, discipline: :wild_magic)
      apprentice_entry.entry_pool_disciplines.create!(pool: pool, discipline: "wild_magic")
      apprentice_entry.entry_spells.create!(pool: pool, spell: spell)

      resolved = apprentice_entry.resolved_pools.first

      # eligible_disciplines/slot_count come from the mentor's pool...
      expect(resolved[:of]).to eq(1)
      expect(resolved[:eligible_disciplines]).to match_array(%w[wild_magic divinity])
      expect(resolved[:slot_count]).to eq(2)
      # ...but the apprentice's own picks stay hers.
      expect(resolved[:chosen_disciplines]).to eq(["wild_magic"])
      expect(resolved[:spells]).to eq([spell])
    end

    it "always resolves of: 1 for a mentor_derived pool, even when the mentor's own pool has of > 1" do
      # A Doctor of the Firmament-shaped mentor: Aetheric Gaze lets *her* pick from 2 of 3
      # Disciplines at once. Apprenticeship only ever copies the plain Mage ability, not that
      # separate special rule, so the apprentice must still only ever pick one Discipline.
      mentor_profile = create(:profile)
      mentor_profile.replace_spell_pools!([ {
        of: 2, slot_count: 4, mage_slot_count: 2, disciplines: %w[blood_rites fateweaving wild_magic]
      } ])
      mentor_entry = create(:list_entry, entry: create(:reference, profile: mentor_profile))

      apprentice_profile = create(:profile)
      apprentice_profile.replace_spell_pools!([ {
        of: 1, slot_count: 0, mentor_derived: true, grants_cantrip: true, disciplines: []
      } ])
      apprentice_entry = create(:list_entry, list: mentor_entry.list, entry: create(:reference, profile: apprentice_profile),
                                 mentored_by_entry: mentor_entry)

      resolved = apprentice_entry.resolved_pools.first

      expect(resolved[:of]).to eq(1)
      expect(resolved[:eligible_disciplines]).to match_array(%w[blood_rites fateweaving wild_magic])
      expect(resolved[:slot_count]).to eq(2)
    end

    it "falls back to no discipline access when no mentor has been chosen yet" do
      profile = create(:profile)
      profile.replace_spell_pools!([ { of: 1, slot_count: 0, mentor_derived: true, disciplines: [] } ])
      entry = create(:list_entry, entry: create(:reference, profile: profile))

      resolved = entry.resolved_pools.first

      expect(resolved[:eligible_disciplines]).to eq([])
      expect(resolved[:slot_count]).to eq(0)
    end

    it "auto-fills every spell of the eligible Discipline for an unlimited pool, with nothing picked" do
      profile = create(:profile)
      profile.replace_spell_pools!([ {
        of: 1, slot_count: 0, unlimited: true, grants_cantrip: true, resets_each_round: false,
        disciplines: %w[wild_magic]
      } ])
      entry = create(:list_entry, entry: create(:reference, profile: profile))
      known = create_list(:spell, 2, discipline: :wild_magic)
      cantrip = create(:spell, discipline: :wild_magic, cantrip: true)
      create(:spell, discipline: :divinity) # a different Discipline's spell must not leak in

      resolved = entry.resolved_pools.first

      expect(resolved[:chosen_disciplines]).to eq(["wild_magic"])
      expect(resolved[:spells]).to match_array(known)
      expect(resolved[:spells]).not_to include(cantrip)
      expect(entry.entry_pool_disciplines).to be_empty
      expect(entry.entry_spells).to be_empty
    end
  end

  describe "mentor validation" do
    it "rejects a mentor from a different list" do
      other_mentor = create(:list_entry)
      entry = build(:list_entry, mentored_by_entry: other_mentor)

      expect(entry).not_to be_valid
      expect(entry.errors[:mentored_by_entry]).to be_present
    end

    it "accepts a mentor in the same list" do
      list = create(:list)
      mentor = create(:list_entry, list: list, position: 1)
      entry = build(:list_entry, list: list, position: 2, mentored_by_entry: mentor)

      expect(entry).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id                    :bigint           not null, primary key
#  entry_type            :string           not null
#  position              :integer          not null
#  summoned              :boolean          default(FALSE), not null
#  upgrade_selected      :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  companion_of_entry_id :bigint
#  entry_id              :bigint           not null
#  list_id               :bigint           not null
#  mentored_by_entry_id  :bigint
#
# Indexes
#
#  index_list_entries_on_companion_of_entry_id    (companion_of_entry_id)
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#  index_list_entries_on_mentored_by_entry_id     (mentored_by_entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (companion_of_entry_id => list_entries.id) ON DELETE => cascade
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (mentored_by_entry_id => list_entries.id) ON DELETE => nullify
#
