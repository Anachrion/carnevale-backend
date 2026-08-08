require 'rails_helper'

RSpec.describe Gang::TextFormat do
  let(:user) { create(:user) }

  # The two profiles that make this format non-trivial, reproduced rather than fetched from the
  # catalog so the spec states the shape it depends on.
  #
  #   * A "Seamstress": two pools with the *same* eligible Disciplines, the second granting no
  #     cantrip (Entwined Magics). Nothing in a selection can tell those two apart, which is why
  #     the format binds by label.
  #   * A "Tarot Reader": a second pool with no spell slots at all, whose chosen Discipline *is*
  #     an extra cantrip (Minor Arcana).
  def seamstress
    @seamstress ||= create(:profile, name: "Seamstress", faction: "guild").tap do |p|
      rule = Catalog::SpecialRule.create!(name: "Entwined Magics", description: "…")
      p.replace_spell_pools!([
        { of: 1, slot_count: 1, grants_cantrip: true, disciplines: %w[divinity fateweaving] },
        { of: 1, slot_count: 1, grants_cantrip: false, special_rule_id: rule.id, disciplines: %w[divinity fateweaving] }
      ])
      create(:card_reference, profile: p, identifier: "guild-seamstress-a")
    end
  end

  def tarot_reader
    @tarot_reader ||= create(:profile, name: "Tarot Reader", faction: "guild").tap do |p|
      rule = Catalog::SpecialRule.create!(name: "Minor Arcana", description: "…")
      p.replace_spell_pools!([
        { of: 1, slot_count: 2, grants_cantrip: true, disciplines: %w[fateweaving wild_magic] },
        { of: 1, slot_count: 0, grants_cantrip: true, special_rule_id: rule.id, disciplines: %w[fateweaving wild_magic] }
      ])
      create(:card_reference, profile: p, identifier: "guild-tarot-a")
    end
  end

  def plain_model(name)
    profile = create(:profile, name: name, faction: "guild")
    create(:card_reference, profile: profile, identifier: "guild-#{name.parameterize}-a")
    profile
  end

  def select!(entry, pool_index, disciplines: [], spells: [])
    pool = entry.profile.profile_spell_pools.to_a[pool_index]
    disciplines.each { |d| entry.entry_pool_disciplines.create!(pool_id: pool.id, discipline: d) }
    spells.each { |s| entry.entry_spells.create!(pool_id: pool.id, spell: s) }
  end

  describe "a round trip" do
    it "rebuilds a gang that dumps to exactly the same text" do
      unravel = create(:spell, name: "Unravel", discipline: :fateweaving)
      mend = create(:spell, name: "Radiant Mend", discipline: :divinity)
      plain_model("Bravo")
      equipment = create(:equipment, name: "Climbing Tools")

      list = create(:list, owner: user, name: "Blood of the Lamb", faction: "guild", points: 150)
      s = list.list_entries.create!(entry: seamstress.card_references.first, position: 1)
      select!(s, 0, disciplines: %w[divinity], spells: [ mend ])
      select!(s, 1, disciplines: %w[fateweaving], spells: [ unravel ])
      t = list.list_entries.create!(entry: tarot_reader.card_references.first, position: 2)
      select!(t, 0, disciplines: %w[fateweaving], spells: [ unravel ])
      # The extra cantrip: a Discipline and no spells at all.
      select!(t, 1, disciplines: %w[wild_magic])
      list.list_entries.create!(entry: Catalog::Profile.find_by(name: "Bravo").card_references.first, position: 3)
      list.list_entries.create!(entry: equipment, position: 4)

      original = described_class.dump(list.reload)
      imported = Gang::TextImport.call(original, owner: user)

      expect(imported.warnings).to be_empty
      expect(described_class.dump(imported.list)).to eq(original)
    end
  end

  describe "#dump" do
    it "binds each selection to its pool by label, not by position" do
      mend = create(:spell, name: "Radiant Mend", discipline: :divinity)
      list = create(:list, owner: user, faction: "guild")
      entry = list.list_entries.create!(entry: seamstress.card_references.first, position: 1)
      # Only the *second* pool is filled. Position alone could not express that; the label can.
      select!(entry, 1, disciplines: %w[divinity], spells: [ mend ])

      expect(described_class.dump(list.reload)).to include("  Entwined Magics: Divinity > Radiant Mend")
      expect(described_class.dump(list.reload)).not_to include("  Discipline: Divinity")
    end

    it "writes a cantrip-only pool as its Discipline alone" do
      list = create(:list, owner: user, faction: "guild")
      entry = list.list_entries.create!(entry: tarot_reader.card_references.first, position: 1)
      select!(entry, 1, disciplines: %w[wild_magic])

      expect(described_class.dump(list.reload)).to include("  Minor Arcana: Wild Magic")
    end

    # Adventuring Noble's Arcane Totem: it knows every spell of its Discipline outright. Nothing was
    # picked, so there is nothing to write down — and nothing import would need to restore.
    it "writes nothing for an unlimited pool" do
      noble = create(:profile, name: "Adventuring Noble", faction: "guild")
      noble.replace_spell_pools!([ { of: 1, slot_count: 0, grants_cantrip: true, unlimited: true, disciplines: %w[wild_magic] } ])
      create(:card_reference, profile: noble, identifier: "guild-noble-a")
      list = create(:list, owner: user, faction: "guild")
      list.list_entries.create!(entry: noble.card_references.first, position: 1)

      dumped = described_class.dump(list.reload)

      expect(dumped).to include("- Adventuring Noble")
      expect(dumped).not_to include("Discipline")
    end

    it "leaves auto-included companions out" do
      parent = plain_model("Emissary of Mother Hydra")
      tentacle = create(:profile, name: "Dagger Tentacle", faction: "guild", recruitable: false)
      create(:card_reference, profile: tentacle, identifier: "guild-tentacle-a")
      create(:profile_companion, profile: parent, companion_profile: tentacle, base_quantity: 2)

      list = create(:list, owner: user, faction: "guild")
      entry = list.list_entries.create!(entry: parent.card_references.first, position: 1)
      CompanionSyncService.call(entry)

      expect(list.reload.list_entries.count).to eq(3)
      expect(described_class.dump(list)).not_to include("Tentacle")
    end
  end

  describe "#parse" do
    it "accepts a Discipline written as a label, a slug, or run together" do
      %w[Fateweaving fateweaving FATEWEAVING].each do |written|
        expect(described_class.discipline_from(written)).to eq("fateweaving")
      end
      expect(described_class.discipline_from("Runes of Sovereignty")).to eq("runes_of_sovereignty")
      expect(described_class.discipline_from("runes_of_sovereignty")).to eq("runes_of_sovereignty")
      expect(described_class.discipline_from("RunesOfSovereignty")).to eq("runes_of_sovereignty")
    end

    it "reports the line number of anything it cannot read" do
      result = described_class.parse("Carnevale gang: X\nWobble\nDucats: many\n")

      expect(result.warnings).to include(a_string_matching(/line 2/), a_string_matching(/line 3.*whole number/))
    end
  end
end
