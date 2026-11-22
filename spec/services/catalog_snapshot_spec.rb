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

  # CARNEVALEB-84: everything the backoffice can edit must survive the dev seed. One catalog with
  # every exception shape the rake tasks used to set by name.
  describe "advanced options, spell pools, grants, companions, glossary and spells" do
    def build_exceptions!
      Catalog::Ability.create!(category: "character", name: "Mage", description: "Knows (X) spells.")
      tarot = Catalog::SpecialRule.create!(name: "Minor Arcana", description: "An extra Cantrip.")
      baptism = Catalog::SpecialRule.create!(name: "", spell_name: "Dagonite Baptism", description: "")
      waves = Catalog::Spell.create!(name: "Waves of Force", discipline: :divinity, cost: 1, difficulty: 6, description: "Push.")
      Catalog::Spell.create!(name: "Cantrip of Fate", discipline: :fateweaving, cost: 0, difficulty: 7, cantrip: true)

      reader = create(:profile, faction: "guild", name: "Tarot Reader", abilities: [ "Mage (2)" ],
                                distinct_discipline_per_copy: true)
      create(:card_reference, profile: reader, identifier: "guild-tarot-reader")
      reader.replace_spell_pools!([
        { of: 1, slot_count: 3, mage_slot_count: 2, disciplines: %w[fateweaving wild_magic] },
        { of: 1, slot_count: 0, distinct_from_other_pools: true, special_rule_id: tarot.id, disciplines: %w[fateweaving] },
        { of: 1, slot_count: 0, unlimited: true, resets_each_round: false, disciplines: %w[wild_magic] }
      ])
      reader.replace_granted_spells!([
        { grant_kind: "named_spell", spell_id: waves.id },
        { grant_kind: "named_spell", unique_spell_name: "Dagonite Baptism", unique_spell_cost: 1,
          unique_spell_difficulty: 6, unique_spell_description: "Drown.", special_rule_id: baptism.id },
        { grant_kind: "all_cantrips" }
      ])

      apprentice = create(:profile, faction: "guild", name: "Apprentice Doctor")
      create(:card_reference, profile: apprentice, identifier: "guild-apprentice-doctor")
      apprentice.replace_spell_pools!([ { of: 1, slot_count: 0, mentor_derived: true, disciplines: [] } ])

      capitano = create(:profile, faction: "guild", name: "Il Capitano", keywords: [ "Leader" ])
      create(:card_reference, profile: capitano, identifier: "guild-il-capitano")
      signora = create(:profile, faction: "guild", name: "La Signora", keywords: [ "Leader" ],
                                 flexible_leader: true, flexible_leader_with: capitano)
      create(:card_reference, profile: signora, identifier: "guild-la-signora")

      tentacle = create(:profile, faction: "guild", name: "Maw Tentacle", recruitable: false)
      create(:card_reference, profile: tentacle, identifier: "guild-maw-tentacle")
      emissary = create(:profile, faction: "guild", name: "Emissary", companion_upgrade_ducats: 12)
      create(:card_reference, profile: emissary, identifier: "guild-emissary")
      emissary.replace_companions!([ { companion_profile_id: tentacle.id, base_quantity: 1, upgraded_quantity: 2 } ])
    end

    def wipe_catalog!
      [ Catalog::ProfileCompanion, Catalog::ProfileGrantedSpell, Catalog::ProfileSpellPoolDiscipline,
        Catalog::ProfileSpellPool, Catalog::ProfileWeapon, Catalog::ProfileSpecialRule, Catalog::CardReference,
        Catalog::Illustration ].each(&:delete_all)
      Catalog::Profile.update_all(flexible_leader_with_id: nil)
      [ Catalog::Profile, Catalog::Weapon, Catalog::SpecialRule, Catalog::Ability, Catalog::Spell ].each(&:delete_all)
    end

    it "exports, imports into an empty catalog, and exports the very same files again" do
      build_exceptions!
      described_class.export(dir: dir)
      first = %w[abilities spells weapons special_rules profiles].to_h { |f| [ f, dir.join("#{f}.yml").read ] }

      wipe_catalog!
      described_class.import(dir: dir)
      again = Pathname(Dir.mktmpdir)
      described_class.export(dir: again)

      first.each { |name, content| expect(again.join("#{name}.yml").read).to eq(content), "#{name}.yml differs" }
      FileUtils.remove_entry(again)
    end

    it "restores the shapes the game logic reads" do
      build_exceptions!
      described_class.export(dir: dir)
      wipe_catalog!
      described_class.import(dir: dir)

      reader = Catalog::Profile.find_by!(name: "Tarot Reader")
      expect(reader.distinct_discipline_per_copy).to be(true)
      expect(reader.profile_spell_pools.order(:position).map { |p| [ p.mage_slot_count, p.distinct_from_other_pools, p.unlimited ] })
        .to eq([ [ 2, false, false ], [ 0, true, false ], [ 0, false, true ] ])
      expect(reader.profile_granted_spells.order(:position).map { |g| g.resolved_name || g.grant_kind })
        .to eq([ "Waves of Force", "Dagonite Baptism", "all_cantrips" ])
      expect(Catalog::Profile.find_by!(name: "Apprentice Doctor").profile_spell_pools.sole.mentor_derived).to be(true)
      expect(Catalog::Profile.find_by!(name: "La Signora").flexible_leader_with.name).to eq("Il Capitano")
      expect(Catalog::Profile.find_by!(name: "Maw Tentacle").recruitable).to be(false)
      emissary = Catalog::Profile.find_by!(name: "Emissary")
      expect(emissary.companion_upgrade_ducats).to eq(12)
      expect(emissary.profile_companions.map { |c| [ c.companion_profile.name, c.base_quantity, c.upgraded_quantity ] })
        .to eq([ [ "Maw Tentacle", 1, 2 ] ])
      expect(Catalog::Spell.cantrip_for("fateweaving").name).to eq("Cantrip of Fate")
    end

    it "keeps the players' spell picks when re-importing an unchanged snapshot" do
      build_exceptions!
      reader = Catalog::Profile.find_by!(name: "Tarot Reader")
      pool = reader.profile_spell_pools.order(:position).first
      list = create(:list, faction: :guild, points: 100)
      entry = Gang::Entry.new(list: list, entry: reader.card_references.first, position: 1).tap { |e| e.save(validate: false) }
      Gang::EntrySpell.new(list_entry: entry, spell: create(:spell, discipline: :fateweaving), pool: pool).save!(validate: false)
      described_class.export(dir: dir)

      described_class.import(dir: dir)

      expect(entry.entry_spells.pluck(:pool_id)).to eq([ pool.id ])
    end

    # A cantrip renamed in the backoffice reaches the snapshot under its new name, while a fresh
    # seed first creates the original from db/seeds/spells.rb: two cantrips in one discipline.
    it "imports a renamed cantrip over the seeded original" do
      Catalog::Spell.create!(name: "Cantrip of the Sun", discipline: :divinity, cost: 0, difficulty: 7, cantrip: true)
      dir.join("spells.yml").write([ { "discipline" => "divinity", "name" => "Cantrip of the Dawn", "cost" => 0,
                                       "difficulty" => 7, "description" => "", "cantrip" => true } ].to_yaml)

      described_class.import(dir: dir)

      expect(Catalog::Spell.cantrip_for("divinity").name).to eq("Cantrip of the Dawn")
      expect(Catalog::Spell.find_by!(name: "Cantrip of the Sun").cantrip).to be(false)
    end

    it "leaves pools, grants and companions alone when importing an older snapshot without them" do
      build_exceptions!
      described_class.export(dir: dir)
      profiles = YAML.safe_load(dir.join("profiles.yml").read)
      profiles.each { |p| p.except!("spell_pools", "granted_spells", "companions", "flexible_leader_with", *described_class::PROFILE_FLAGS) }
      dir.join("profiles.yml").write(profiles.to_yaml)

      described_class.import(dir: dir)

      expect(Catalog::Profile.find_by!(name: "Tarot Reader").profile_spell_pools.count).to eq(3)
      expect(Catalog::Profile.find_by!(name: "Emissary").profile_companions.count).to eq(1)
      expect(Catalog::Profile.find_by!(name: "Maw Tentacle").recruitable).to be(false)
    end
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

  # Which weapon a model carries is a choice the player makes, so it is catalog, not render
  # bookkeeping — losing it on a rebuild would silently reprint the card as "carries both".
  it "carries the weapon choice across the round trip" do
    spear   = Catalog::Weapon.create!(name: "Pole Spear & Net", damage: 1)
    harpoon = Catalog::Weapon.create!(name: "Harpoon Gun", damage: 1, range: 12)
    fisherman = create(:card_reference, identifier: "guild-fisherman").profile
    fisherman.update!(exclusive_weapons: true)
    Catalog::ProfileWeapon.create!(profile: fisherman, weapon: spear, position: 1)
    Catalog::ProfileWeapon.create!(profile: fisherman, weapon: harpoon, position: 2)

    described_class.export(dir: dir)
    [ Catalog::ProfileWeapon, Catalog::CardReference, Catalog::Profile, Catalog::Weapon ].each(&:delete_all)
    described_class.import(dir: dir)

    expect(Catalog::Profile.find_by!(name: fisherman.name).exclusive_weapons).to be(true)
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
