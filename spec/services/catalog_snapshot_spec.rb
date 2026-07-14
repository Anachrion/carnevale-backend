require "rails_helper"
require "tmpdir"

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe CatalogSnapshot do
  let(:dir) { Pathname(Dir.mktmpdir) }
  after { FileUtils.remove_entry(dir) }

  # A small but representative catalog: a profile with stats, keywords and abilities, a shared
  # weapon and rule, an A/B pair of card references, and two illustrations — one carrying an
  # uploaded blob, one a committed asset path.
  def build_catalog!
    Catalog::Ability.create!(category: "weapon", name: "Reach")
    weapon = Catalog::Weapon.create!(name: "Rapier", damage: 2, penetration: -1, abilities: [ "Reach" ])
    rule = Catalog::SpecialRule.create!(name: "Brave", description: "Ignores Fear.")

    profile = create(:profile, faction: "guild", name: "Duellist", ducats: 18,
      keywords: [ "Leader" ], abilities: [ "Acrobatic (2)" ])
    Catalog::ProfileWeapon.create!(profile: profile, weapon: weapon, position: 1)
    Catalog::ProfileSpecialRule.create!(profile: profile, special_rule: rule, position: 1)

    create(:card_reference, profile: profile, identifier: "guild-duellist-a", illustration_number: 1)
    create(:card_reference, profile: profile, identifier: "guild-duellist-b", illustration_number: 2)

    uploaded = profile.illustrations.build(number: 1, path: "", offset_x: 10, zoom: 120)
    uploaded.image.attach(io: file_fixture("art.png").open, filename: "art.png")
    uploaded.save!
    profile.illustrations.create!(number: 2, path: "p07.png", offset_y: -30)

    profile
  end

  it "round-trips the catalog through export and import into a wiped database" do
    build_catalog!
    described_class.export(dir: dir)

    # Wipe every catalog table, then rebuild purely from the snapshot.
    [ Catalog::ProfileWeapon, Catalog::ProfileSpecialRule, Catalog::CardReference,
      Catalog::Illustration, Catalog::Profile, Catalog::Weapon, Catalog::SpecialRule ].each(&:delete_all)

    described_class.import(dir: dir)

    profile = Catalog::Profile.find_by!(name: "Duellist")
    expect(profile).to have_attributes(faction: "guild", ducats: 18, keywords: [ "Leader" ], abilities: [ "Acrobatic (2)" ])
    expect(profile.weapons.map(&:name)).to eq([ "Rapier" ])
    expect(profile.weapons.first.abilities).to eq([ "Reach" ])
    expect(profile.special_rules.map(&:name)).to eq([ "Brave" ])
    expect(profile.card_references.map(&:identifier)).to contain_exactly("guild-duellist-a", "guild-duellist-b")

    first = profile.illustrations.find_by(number: 1)
    expect(first.image).to be_attached
    expect(first.image.download).to eq(file_fixture("art.png").binread)
    expect(first.offset_x).to eq(10)
    expect(profile.illustrations.find_by(number: 2).path).to eq("p07.png")
  end

  it "is idempotent — a second import neither duplicates nor errors" do
    build_catalog!
    described_class.export(dir: dir)

    described_class.import(dir: dir)
    expect {
      described_class.import(dir: dir)
    }.to not_change(Catalog::Profile, :count).and not_change(Catalog::Weapon, :count)

    expect(Catalog::Profile.find_by(name: "Duellist").weapons.count).to eq(1)
  end

  it "collapses identical shared records but keeps same-named distinct ones" do
    # Two weapons share a name but differ in stats: both must survive the round trip as two rows.
    w1 = Catalog::Weapon.create!(name: "Pistol", damage: 3)
    w2 = Catalog::Weapon.create!(name: "Pistol", damage: 5)
    p1 = create(:card_reference, identifier: "guild-a").profile
    p2 = create(:card_reference, identifier: "guild-b").profile
    Catalog::ProfileWeapon.create!(profile: p1, weapon: w1, position: 1)
    Catalog::ProfileWeapon.create!(profile: p2, weapon: w2, position: 1)

    described_class.export(dir: dir)
    [ Catalog::ProfileWeapon, Catalog::CardReference, Catalog::Profile, Catalog::Weapon ].each(&:delete_all)
    described_class.import(dir: dir)

    expect(Catalog::Weapon.where(name: "Pistol").pluck(:damage)).to contain_exactly(3, 5)
    expect(Catalog::Profile.find_by(name: p1.name).weapons.first.damage).to eq(3)
  end
end
