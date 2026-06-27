require 'rails_helper'

RSpec.describe ListEntry, type: :model do
  let(:list) { create(:list, faction: :guild, points: 100) }

  def guild_ref(cost: 10, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  describe "on create" do
    it "is valid with a matching faction and enough points" do
      entry = list.list_entries.build(card_reference: guild_ref, position: 1)
      expect(entry).to be_valid
    end

    it "is invalid when the card pushes the list over budget" do
      entry = list.list_entries.build(card_reference: guild_ref(cost: 101), position: 1)
      expect(entry).not_to be_valid
      expect(entry.errors[:base].first).to match(/exceeds the 100 points limit/)
    end

    it "is invalid when the card belongs to a different faction" do
      profile = create(:profile, faction: :rashaar, ducats: 10)
      ref = create(:card_reference, profile: profile)
      entry = list.list_entries.build(card_reference: ref, position: 1)
      expect(entry).not_to be_valid
      expect(entry.errors[:base].first).to match(/rashaar/)
    end

    it "is invalid when adding a Unique card already in the list" do
      ref = guild_ref(keywords: ["Unique"])
      create(:list_entry, list: list, card_reference: ref, position: 1)

      duplicate = list.list_entries.build(card_reference: ref, position: 2)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base].first).to match(/Unique and can only be hired once/)
    end

    it "does not re-run roster validation on update" do
      profile = create(:profile, faction: :guild, ducats: 10)
      ref = create(:card_reference, profile: profile)
      entry = create(:list_entry, list: list, card_reference: ref, position: 1)

      profile.update!(ducats: 200)
      entry.touch
      expect(entry).to be_valid
    end
  end
end
