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

    # B-26: the entry association is polymorphic (no FK), so a catalog row can be deleted out from
    # under an entry, leaving it orphaned. Validation runs inside an after_commit, so a nil-deref
    # here would raise on every later edit to the list. It must skip the orphan, not blow up.
    it "doesn't raise when an entry's catalog record has been deleted" do
      ref = guild_ref(cost: 10, keywords: ["Leader"])
      add_entry(list, ref)
      ref.delete # orphan the entry: entry_id now points at a row that's gone

      expect { described_class.call(list.reload) }.not_to raise_error
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

      it "sums the cost of every entry against the limit" do
        add_entry(list, guild_ref(cost: 50), position: 1)
        add_entry(list, guild_ref(cost: 60), position: 2)

        result = described_class.call(list)
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

      it "fails when two Unique entries for the same card exist in the list" do
        ref = guild_ref(cost: 10, keywords: ["Leader", "Unique"])
        add_entry(list, ref, position: 1)
        add_entry(list, ref, position: 2)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors].first).to match(/Unique and can only be hired once/)
      end

      # B-25: the same Unique character fielded via two *different* card references of one profile
      # (an A/B pair) must still be caught — the check groups by profile, not card reference.
      it "fails for two different references of the same Unique profile" do
        profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Leader", "Unique"])
        ref_a = create(:card_reference, profile: profile, identifier: "guild-unique-a")
        ref_b = create(:card_reference, profile: profile, identifier: "guild-unique-b")
        add_entry(list, ref_a, position: 1)
        add_entry(list, ref_b, position: 2)

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

      # Flex Leaders (The Duke, Prince of Thieves, Sopracomito, La Signora): print both Leader and
      # Hero, drop Leader alongside another Leader, drop Hero when they're the only Leader.
      def flex_leader_ref(cost: 10)
        profile = create(:profile, faction: :guild, ducats: cost, keywords: ["Leader", "Hero"], flexible_leader: true)
        create(:card_reference, profile: profile)
      end

      it "allows a flex Leader alongside a hard Leader (it demotes to a Hero)" do
        add_entry(list, guild_ref(cost: 10, keywords: ["Leader"]), position: 1)
        add_entry(list, flex_leader_ref, position: 2)
        # The demoted flex Leader is now a Hero, so it needs a Henchman to keep the ratio.
        add_entry(list, guild_ref(cost: 10, keywords: ["Henchman"]), position: 3)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "counts a demoted flex Leader as a Hero for the Hero/Henchman ratio" do
        add_entry(list, guild_ref(cost: 10, keywords: ["Leader"]), position: 1)
        add_entry(list, flex_leader_ref, position: 2) # demotes to Hero, no Henchman to match

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/more Heroes.*than Henchmen/))
      end

      it "treats a lone flex Leader as the Leader (and not a Hero)" do
        add_entry(list, flex_leader_ref, position: 1)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "fails when two flex Leaders are the only Leaders (both demote, leaving none)" do
        add_entry(list, flex_leader_ref, position: 1)
        add_entry(list, flex_leader_ref, position: 2)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/must have exactly one Leader/))
      end

      # La Signora is a *conditional* flex Leader: she demotes only alongside her named partner
      # (Il Capitano), not any Leader.
      def partner_ref
        create(:card_reference, profile: create(:profile, faction: :gifted, ducats: 10, keywords: ["Leader"]))
      end

      def conditional_flex_ref(partner:)
        profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Leader", "Hero"],
                         flexible_leader: true, flexible_leader_with: partner.profile)
        create(:card_reference, profile: profile)
      end

      it "demotes a conditional flex Leader alongside her named partner" do
        capitano = partner_ref
        add_entry(list, capitano, position: 1)
        add_entry(list, conditional_flex_ref(partner: capitano), position: 2) # demotes → Hero
        add_entry(list, guild_ref(cost: 10, keywords: ["Henchman"]), position: 3)

        result = described_class.call(list)
        expect(result[:success]).to be true
      end

      it "does not demote a conditional flex Leader alongside a different Leader" do
        capitano = partner_ref # her partner, but NOT the one in the gang
        add_entry(list, guild_ref(cost: 10, keywords: ["Leader"]), position: 1)
        add_entry(list, conditional_flex_ref(partner: capitano), position: 2) # keeps Leader → two

        result = described_class.call(list)
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

      # save!(validate: false): a non-Mage profile has no pool at all (pool_id stays nil, which the
      # DB allows on entry_spells specifically), so this simulates spells attached despite that
      # (stale client, direct DB edit) — exercising ListValidationService's own "not a Mage" check
      # independent of the model-level validations that would normally prevent it through the app.
      # entry_pool_disciplines.pool_id has no such escape hatch (NOT NULL in the DB), so it's only
      # created when there's a real pool to attach it to.
      def cast(entry, discipline:, spells:)
        pool = entry.profile&.profile_spell_pools&.first
        entry.entry_pool_disciplines.create!(pool: pool, discipline: discipline) if pool
        spells.each { |spell| Gang::EntrySpell.new(list_entry: entry, spell: spell, pool: pool).save!(validate: false) }
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
        expect(result[:errors]).to include(match(/can only know spells from its committed Discipline/))
      end

      it "rejects knowing more spells than the model's slots allow" do
        entry = add_entry(list, mage_ref(mage: 2, expert: 1))
        cast(entry, discipline: "blood_rites", spells: create_list(:spell, 4, discipline: :blood_rites))

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(%r{knows too many spells \(4/3\)}))
      end

      context "a pool flagged distinct_from_other_pools (Tarot Reader's Minor Arcana)" do
        def two_pool_ref
          profile = create(:profile, faction: :guild, ducats: 20, keywords: ["Leader"])
          profile.replace_spell_pools!([
            { of: 1, slot_count: 2, mage_slot_count: 2, grants_cantrip: true, disciplines: %w[blood_rites divinity] },
            { of: 1, slot_count: 0, grants_cantrip: true, distinct_from_other_pools: true, disciplines: %w[blood_rites divinity] }
          ])
          create(:card_reference, profile: profile)
        end

        it "accepts a different Discipline for the flagged pool" do
          entry = add_entry(list, two_pool_ref)
          pools = entry.profile.profile_spell_pools.order(:position)
          entry.entry_pool_disciplines.create!(pool: pools.first, discipline: "blood_rites")
          entry.entry_pool_disciplines.create!(pool: pools.second, discipline: "divinity")

          result = described_class.call(list)
          expect(result[:success]).to be true
        end

        it "rejects the same Discipline as another pool on the same model" do
          entry = add_entry(list, two_pool_ref)
          pools = entry.profile.profile_spell_pools.order(:position)
          entry.entry_pool_disciplines.create!(pool: pools.first, discipline: "blood_rites")
          entry.entry_pool_disciplines.create!(pool: pools.second, discipline: "blood_rites")

          result = described_class.call(list)
          expect(result[:success]).to be false
          expect(result[:errors]).to include(match(/must pick a different Discipline for this pool/))
        end
      end
    end

    context "Apprentice Doctor's Apprenticeship mentor" do
      # "Leader" here is just to satisfy the outer list's own Leader-count rule — unrelated to the
      # Apprenticeship keyword check under test, which cares only about Hero + Doctor.
      def doctor_hero_ref(name: "Mentor Doctor")
        profile = create(:profile, name: name, faction: :guild, ducats: 20, keywords: ["Hero", "Doctor", "Leader"],
                          abilities: ["Mage (2)"])
        create(:card_reference, profile: profile)
      end

      def apprentice_ref(name: "Apprentice")
        profile = create(:profile, name: name, faction: :guild, ducats: 10, keywords: ["Henchman", "Doctor"])
        profile.replace_spell_pools!([ { of: 1, slot_count: 0, mentor_derived: true, grants_cantrip: true, disciplines: [] } ])
        create(:card_reference, profile: profile)
      end

      it "accepts a mentor with both the Hero and Doctor keywords" do
        mentor = add_entry(list, doctor_hero_ref)
        add_entry(list, apprentice_ref).update!(mentored_by_entry: mentor)

        expect(described_class.call(list)[:success]).to be true
      end

      it "rejects a mentor missing the Hero or Doctor keyword" do
        non_hero = create(:profile, faction: :guild, ducats: 20, keywords: ["Doctor"], abilities: ["Mage (2)"])
        mentor = add_entry(list, create(:card_reference, profile: non_hero))
        add_entry(list, apprentice_ref).update!(mentored_by_entry: mentor)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/mentor must have both the Hero and Doctor keywords/))
      end

      it "rejects a mentor already mentoring another Apprentice Doctor" do
        mentor = add_entry(list, doctor_hero_ref)
        add_entry(list, apprentice_ref(name: "Apprentice A")).update!(mentored_by_entry: mentor)
        add_entry(list, apprentice_ref(name: "Apprentice B")).update!(mentored_by_entry: mentor)

        result = described_class.call(list)
        expect(result[:success]).to be false
        expect(result[:errors]).to include(match(/can only mentor one Apprentice Doctor/))
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
