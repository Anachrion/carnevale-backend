require 'rails_helper'

RSpec.describe EntrySerializer do
  # Every key GrantedSpell (doc/openapi.yaml) requires on the wire — regression coverage for a real
  # bug: the all_cantrips branch of #granted_spell_json reused #spell_json's shape (built for
  # PoolSpell) and silently omitted consumes_slot/resets_each_round/rule, which the dart-dio client
  # then failed to deserialize for every all_cantrips profile (Blood Crone) and poisoned any gang
  # response that included one.
  REQUIRED_GRANTED_SPELL_KEYS = %i[key id discipline name cost difficulty description cantrip
                                    consumes_slot resets_each_round rule cast].freeze

  def cantrips
    Catalog::Spell.cantrips.index_by(&:discipline)
  end

  it "exposes flexible_leader from the entry's profile (defaulting false)" do
    flex = create(:profile, keywords: ["Leader", "Hero"], flexible_leader: true)
    plain = create(:profile, keywords: ["Leader"])
    flex_entry = create(:list_entry, entry: create(:card_reference, profile: flex))
    plain_entry = create(:list_entry, entry: create(:card_reference, profile: plain))

    expect(EntrySerializer.new(flex_entry, cantrips: cantrips).as_json[:flexible_leader]).to be true
    expect(EntrySerializer.new(plain_entry, cantrips: cantrips).as_json[:flexible_leader]).to be false
  end

  it "includes every required GrantedSpell key for an all_cantrips grant (Blood Crone's Major Arcana)" do
    Catalog::Spell::DISCIPLINES.each { |d| create(:spell, discipline: d, cantrip: true) }
    profile = create(:profile)
    profile.replace_granted_spells!([ { grant_kind: "all_cantrips", consumes_slot: false, resets_each_round: true } ])
    entry = create(:list_entry, entry: create(:card_reference, profile: profile))

    granted = EntrySerializer.new(entry, cantrips: cantrips).as_json[:granted_spells]

    expect(granted.size).to eq(5)
    granted.each { |g| expect(g.keys).to include(*REQUIRED_GRANTED_SPELL_KEYS) }
  end

  it "includes every required GrantedSpell key for a named_spell grant referencing a real Catalog::Spell" do
    spell = create(:spell, discipline: :runes_of_sovereignty)
    profile = create(:profile)
    profile.replace_granted_spells!([ { grant_kind: "named_spell", consumes_slot: false, resets_each_round: true, spell_id: spell.id } ])
    entry = create(:list_entry, entry: create(:card_reference, profile: profile))

    granted = EntrySerializer.new(entry, cantrips: cantrips).as_json[:granted_spells]

    expect(granted.size).to eq(1)
    expect(granted.first.keys).to include(*REQUIRED_GRANTED_SPELL_KEYS)
  end

  it "includes every required GrantedSpell key for a named_spell grant with a character-unique spell" do
    profile = create(:profile)
    profile.replace_granted_spells!([ {
      grant_kind: "named_spell", consumes_slot: false, resets_each_round: true,
      unique_spell_name: "Dagonite Baptism", unique_spell_cost: 1, unique_spell_difficulty: 6,
      unique_spell_description: "Total up every Ace rolled..."
    } ])
    entry = create(:list_entry, entry: create(:card_reference, profile: profile))

    granted = EntrySerializer.new(entry, cantrips: cantrips).as_json[:granted_spells]

    expect(granted.size).to eq(1)
    expect(granted.first.keys).to include(*REQUIRED_GRANTED_SPELL_KEYS)
    expect(granted.first[:id]).to be_nil
    expect(granted.first[:discipline]).to be_nil
  end

  # B-37: an entry_state broadcast carries these instead of the full entry, so they have to agree
  # with the `cast` flags the same entry's as_json would have produced.
  describe "#spell_cast_flags" do
    it "maps every known and granted spell's key to the cast flag as_json would report" do
      cast = create(:spell, discipline: :runes_of_sovereignty)
      uncast = create(:spell, discipline: :runes_of_sovereignty)
      profile = create(:profile)
      profile.replace_granted_spells!([
        { grant_kind: "named_spell", consumes_slot: false, resets_each_round: true, spell_id: cast.id },
        { grant_kind: "named_spell", consumes_slot: false, resets_each_round: true, spell_id: uncast.id }
      ])
      entry = create(:list_entry, entry: create(:card_reference, profile: profile))
      create(:entry_state, list_entry: entry, spell_casts: { "spell:#{cast.id}" => 2 })

      serializer = EntrySerializer.new(entry.reload, cantrips: cantrips, turn: 2)

      expect(serializer.spell_cast_flags).to eq("spell:#{cast.id}" => true, "spell:#{uncast.id}" => false)
      expect(serializer.spell_cast_flags)
        .to eq(serializer.as_json[:granted_spells].to_h { |g| [ g[:key], g[:cast] ] })
    end

    it "reports a resets_each_round spell cast on an earlier turn as no longer cast" do
      spell = create(:spell, discipline: :runes_of_sovereignty)
      profile = create(:profile)
      profile.replace_granted_spells!([ { grant_kind: "named_spell", consumes_slot: false, resets_each_round: true, spell_id: spell.id } ])
      entry = create(:list_entry, entry: create(:card_reference, profile: profile))
      create(:entry_state, list_entry: entry, spell_casts: { "spell:#{spell.id}" => 1 })

      flags = EntrySerializer.new(entry.reload, cantrips: cantrips, turn: 2).spell_cast_flags

      expect(flags).to eq("spell:#{spell.id}" => false)
    end
  end
end
