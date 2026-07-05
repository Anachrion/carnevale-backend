require 'rails_helper'

RSpec.describe ListValidationService, type: :service do
  let(:list) { create(:list, faction: :guild, points: 100) }

  def guild_ref(cost:, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  def foreign_ref(faction:, cost: 10, keywords: [])
    profile = create(:profile, faction: faction, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  def add_entry(list, ref, position: nil)
    position ||= (list.list_entries.maximum(:position) || 0) + 1
    entry = Gang::Entry.new(list: list, entry: ref, position: position)
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
        ref = guild_ref(cost: 100, keywords: ["Leader"])
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
        leader_ref = guild_ref(cost: 10, keywords: ["Leader"])
        add_entry(list, leader_ref, position: 1)

        profile = create(:profile, faction: :gifted, ducats: 10)
        gifted_ref = create(:card_reference, profile: profile)
        add_entry(list, gifted_ref, position: 2)

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
        leader_ref = guild_ref(cost: 10, keywords: ["Leader"])
        add_entry(list, leader_ref, position: 1)

        ref = guild_ref(cost: 10, keywords: [])
        add_entry(list, ref, position: 2)
        add_entry(list, ref, position: 3)

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

    context "leader requirement" do
      it "succeeds when the list is empty" do
        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "fails when the list has entries but no Leader" do
        ref = guild_ref(cost: 10, keywords: ["Henchman"])
        add_entry(list, ref)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/must have exactly one Leader/))
      end

      it "fails when the list has more than one Leader" do
        leader_a = guild_ref(cost: 10, keywords: ["Leader"])
        leader_b = guild_ref(cost: 10, keywords: ["Leader"])
        add_entry(list, leader_a, position: 1)
        add_entry(list, leader_b, position: 2)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/must have exactly one Leader/))
      end

      it "succeeds when the list has exactly one Leader" do
        leader = guild_ref(cost: 10, keywords: ["Leader"])
        add_entry(list, leader)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "is not enforced when the list is 75 points or less" do
        small_list = create(:list, faction: :guild, points: 75)
        profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Henchman"])
        ref = create(:card_reference, profile: profile)
        add_entry(small_list, ref)

        result = described_class.call(small_list)
        expect(result[:success]).to be true
      end

      it "is enforced once the list exceeds 75 points" do
        bigger_list = create(:list, faction: :guild, points: 76)
        profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Henchman"])
        ref = create(:card_reference, profile: profile)
        add_entry(bigger_list, ref)

        result = described_class.call(bigger_list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/must have exactly one Leader/))
      end
    end

    context "hero/henchman ratio" do
      it "fails when there are more Heroes than Henchmen" do
        leader = guild_ref(cost: 10, keywords: ["Leader"])
        hero_a = guild_ref(cost: 10, keywords: ["Hero"])
        hero_b = guild_ref(cost: 10, keywords: ["Hero"])
        add_entry(list, leader, position: 1)
        add_entry(list, hero_a, position: 2)
        add_entry(list, hero_b, position: 3)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/cannot have more Heroes.*than Henchmen/))
      end

      it "succeeds when Heroes are matched by an equal number of Henchmen" do
        leader = guild_ref(cost: 10, keywords: ["Leader"])
        hero = guild_ref(cost: 10, keywords: ["Hero"])
        henchman = guild_ref(cost: 10, keywords: ["Henchman"])
        add_entry(list, leader, position: 1)
        add_entry(list, hero, position: 2)
        add_entry(list, henchman, position: 3)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "succeeds when there are more Henchmen than Heroes" do
        leader = guild_ref(cost: 10, keywords: ["Leader"])
        hero = guild_ref(cost: 10, keywords: ["Hero"])
        henchman_a = guild_ref(cost: 10, keywords: ["Henchman"])
        henchman_b = guild_ref(cost: 10, keywords: ["Henchman"])
        add_entry(list, leader, position: 1)
        add_entry(list, hero, position: 2)
        add_entry(list, henchman_a, position: 3)
        add_entry(list, henchman_b, position: 4)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end
    end

    context "spell selections" do
      # Mage (2) + Expert Sorcerer (1) => 3 spell slots; may pick from Blood Rites or Divinity.
      def mage_ref(cost: 20, mage: 2, expert: 1, disciplines: ["Blood Rites", "Divinity"])
        abilities = ["Mage (#{mage})"]
        abilities << "Expert Sorcerer (#{expert})" if expert
        keywords = ["Leader", "Discipline (#{disciplines.join(', ')})"]
        profile = create(:profile, faction: :guild, ducats: cost, abilities: abilities, keywords: keywords)
        create(:card_reference, profile: profile)
      end

      def cast(entry, discipline:, spells:)
        entry.update_column(:spell_discipline, discipline)
        spells.each { |spell| Gang::EntrySpell.create!(list_entry: entry, spell: spell) }
      end

      it "accepts spells from an allowed Discipline within the slot limit" do
        entry = add_entry(list, mage_ref)
        cast(entry, discipline: "blood_rites", spells: create_list(:spell, 3, discipline: :blood_rites))

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "does not count Cantrips towards the slot limit" do
        entry = add_entry(list, mage_ref(mage: 2))
        spells = create_list(:spell, 2, discipline: :blood_rites)
        spells << create(:spell, discipline: :blood_rites, cantrip: true)
        cast(entry, discipline: "blood_rites", spells: spells)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "rejects spells on a model that is not a Mage" do
        entry = add_entry(list, guild_ref(cost: 20, keywords: ["Leader"]))
        cast(entry, discipline: "blood_rites", spells: [create(:spell, discipline: :blood_rites)])

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/cannot know spells because it is not a Mage/))
      end

      it "rejects a Discipline the model does not have access to" do
        entry = add_entry(list, mage_ref(disciplines: ["Blood Rites"]))
        cast(entry, discipline: "wild_magic", spells: [create(:spell, discipline: :wild_magic)])

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/cannot use the Wild magic Discipline/))
      end

      it "rejects spells that do not all share the committed Discipline" do
        entry = add_entry(list, mage_ref)
        spells = [create(:spell, discipline: :blood_rites), create(:spell, discipline: :divinity)]
        cast(entry, discipline: "blood_rites", spells: spells)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/all spells must share one Discipline/))
      end

      it "rejects knowing more spells than the model's slots allow" do
        entry = add_entry(list, mage_ref(mage: 2, expert: 1))
        cast(entry, discipline: "blood_rites", spells: create_list(:spell, 4, discipline: :blood_rites))

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(%r{knows too many spells \(4/3\)}))
      end
    end

    it "reports multiple errors at once" do
      over_budget = foreign_ref(faction: :strigoi, cost: 200, keywords: ["Leader"])
      add_entry(list, over_budget)

      result = described_class.call(list)
      expect(result[:success]).to be false
      expect(result[:errors].size).to eq(2)
    end
  end
end
