require 'rails_helper'

RSpec.describe ListValidationService, type: :service do
  let(:list) { create(:list, faction: :guild, points: 100) }

  def guild_ref(cost:, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  def foreign_ref(faction:, cost: 10)
    profile = create(:profile, faction: faction, ducats: cost)
    create(:card_reference, profile: profile)
  end

  def add_entry(list, ref, position: nil)
    position ||= (list.list_entries.maximum(:position) || 0) + 1
    entry = ListEntry.new(list: list, entry: ref, position: position)
    entry.save(validate: false)
    entry
  end

  describe ".call" do
    it "returns success: true and no errors for an empty list" do
      result = described_class.call(list)
      expect(result).to eq(success: true, errors: [])
    end

    context "points limit" do
      it "succeeds when total cost equals the points limit" do
        ref = guild_ref(cost: 100)
        add_entry(list, ref)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "fails when total cost exceeds the points limit" do
        ref = guild_ref(cost: 101)
        add_entry(list, ref)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/exceeds the 100 points limit/)
      end

      it "includes the projected entry cost when adding:" do
        ref = guild_ref(cost: 50)
        add_entry(list, ref)
        new_ref = guild_ref(cost: 60)

        result = described_class.call(list, adding: new_ref)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/exceeds the 100 points limit/)
      end
    end

    context "faction consistency" do
      it "allows gifted references in any faction list" do
        profile = create(:profile, faction: :gifted, ducats: 10)
        gifted_ref = create(:card_reference, profile: profile)
        add_entry(list, gifted_ref)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "rejects references from a different non-gifted faction" do
        ref = foreign_ref(faction: :strigoi, cost: 10)
        add_entry(list, ref)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/strigoi.*cannot join a guild list/)
      end

      it "checks the projected entry faction when adding:" do
        ref = foreign_ref(faction: :patricians, cost: 10)

        result = described_class.call(list, adding: ref)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/patricians/)
      end
    end

    context "unique constraint" do
      it "allows a non-unique card to appear multiple times" do
        ref = guild_ref(cost: 10, keywords: ["Hero"])
        add_entry(list, ref, position: 1)
        add_entry(list, ref, position: 2)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "fails when a Unique card is already in the list and is being added again" do
        ref = guild_ref(cost: 10, keywords: ["Unique"])
        add_entry(list, ref)

        result = described_class.call(list, adding: ref)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/Unique and can only be hired once/)
      end

      it "fails when two Unique entries for the same card exist in the list" do
        ref = guild_ref(cost: 10, keywords: ["Leader", "Unique"])
        add_entry(list, ref, position: 1)
        add_entry(list, ref, position: 2)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/Unique and can only be hired once/)
      end
    end

    it "reports multiple errors at once" do
      over_budget = foreign_ref(faction: :strigoi, cost: 200)
      add_entry(list, over_budget)

      result = described_class.call(list)
      expect(result[:success]).to be false
      expect(result[:errors].size).to eq(2)
    end
  end
end
