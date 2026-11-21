require "rails_helper"

RSpec.describe Catalog::CardSnapshot do
  let(:profile) { create(:profile, name: "Capodecina", ducats: 20, keywords: [ "Leader" ]) }
  let!(:stiletto) { Catalog::Weapon.create!(name: "Stiletto", damage: 1) }
  let!(:pistol)   { Catalog::Weapon.create!(name: "Pistol", damage: 2, range: 12) }
  let!(:musket)   { Catalog::Weapon.create!(name: "Musket", damage: 3, range: 24) }
  let!(:rule)     { Catalog::SpecialRule.create!(name: "Sure Footed", description: "Gain Acrobatic (2).") }

  before do
    profile.replace_weapons!([ stiletto.id, pistol.id ])
    profile.replace_special_rules!([ rule.id ])
    profile.replace_spell_pools!([ { of: 1, slot_count: 2, disciplines: [ "fateweaving", "blood_rites" ] } ])
    profile.replace_granted_spells!([ { grant_kind: "all_cantrips" } ])
  end

  describe ".capture" do
    it "holds the whole card, in print order, with string keys" do
      snapshot = described_class.capture(profile)

      expect(snapshot["attributes"]).to include("name" => "Capodecina", "ducats" => 20, "keywords" => [ "Leader" ])
      expect(snapshot["weapons"]).to eq([ { "id" => stiletto.id, "name" => "Stiletto" }, { "id" => pistol.id, "name" => "Pistol" } ])
      expect(snapshot["special_rules"]).to eq([ { "id" => rule.id, "name" => "Sure Footed" } ])
      expect(snapshot["spell_pools"].first).to include("slot_count" => 2, "disciplines" => [ "blood_rites", "fateweaving" ])
      expect(snapshot["granted_spells"].first).to include("grant_kind" => "all_cantrips")
    end

    it "compares equal to itself after a jsonb round trip" do
      snapshot = described_class.capture(profile)
      version = PaperTrail::Version.create!(item_type: "Catalog::Profile", item_id: profile.id, event: "update", card_snapshot: snapshot)

      expect(version.reload.card_snapshot).to eq(described_class.capture(profile))
    end
  end

  describe ".diff" do
    it "describes stat, keyword, weapon and spell pool changes in plain words" do
      before = described_class.capture(profile)
      profile.update!(ducats: 25, keywords: [ "Leader", "Hero" ])
      profile.replace_weapons!([ pistol.id, musket.id ])
      profile.replace_spell_pools!([ { of: 1, slot_count: 3, disciplines: [ "blood_rites", "fateweaving" ] } ])

      lines = described_class.diff(before, described_class.capture(profile))

      expect(lines).to include("Ducats: 20 → 25", "Keywords: +Hero", "Weapon removed: Stiletto", "Weapon added: Musket",
                               "Spell pool 1: Slot count: 2 → 3")
    end

    it "reports a pure reorder of weapons" do
      before = described_class.capture(profile)
      profile.replace_weapons!([ pistol.id, stiletto.id ])

      expect(described_class.diff(before, described_class.capture(profile))).to eq([ "Weapons reordered" ])
    end

    it "is empty when nothing changed" do
      expect(described_class.diff(described_class.capture(profile), described_class.capture(profile))).to be_empty
    end
  end

  describe ".restore!" do
    it "puts the whole card back as it was" do
      snapshot = described_class.capture(profile)
      profile.update!(ducats: 99, keywords: [])
      profile.replace_weapons!([ musket.id ])
      profile.replace_special_rules!([])
      profile.replace_spell_pools!([])
      profile.replace_granted_spells!([])

      skipped = described_class.restore!(profile, snapshot)

      expect(skipped).to be_empty
      expect(described_class.capture(profile)).to eq(snapshot)
    end

    it "skips a weapon deleted since, and names it" do
      snapshot = described_class.capture(profile)
      profile.replace_weapons!([ pistol.id ])
      stiletto.destroy!

      skipped = described_class.restore!(profile, snapshot)

      expect(skipped).to eq([ "Stiletto" ])
      expect(profile.reload.weapons).to eq([ pistol ])
    end

    it "restores companions too" do
      tentacle = create(:profile, name: "Tentacle")
      profile.replace_companions!([ { companion_profile_id: tentacle.id, base_quantity: 2, upgraded_quantity: 4 } ])
      snapshot = described_class.capture(profile)
      profile.replace_companions!([])

      described_class.restore!(profile, snapshot)

      expect(profile.reload.profile_companions.map { |pc| [ pc.companion_profile_id, pc.base_quantity, pc.upgraded_quantity ] })
        .to eq([ [ tentacle.id, 2, 4 ] ])
    end
  end
end
