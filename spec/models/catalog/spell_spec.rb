require "rails_helper"

RSpec.describe Catalog::Spell do
  describe "one cantrip per discipline" do
    it "is validated, and held by the database for concurrent saves" do
      create(:spell, discipline: :blood_rites, cantrip: true)

      expect(build(:spell, discipline: :blood_rites, cantrip: true)).not_to be_valid
      expect(build(:spell, discipline: :divinity, cantrip: true)).to be_valid
      expect { build(:spell, discipline: :blood_rites, cantrip: true).save!(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # A spell's discipline decides which pools it fits, so moving it can invalidate the gangs that
  # chose it; their cached validity is refreshed rather than left stale.
  describe "changing a chosen spell's discipline" do
    let(:list) { create(:list, faction: :guild, points: 100) }
    let(:spell) { create(:spell, discipline: :blood_rites) }

    before do
      profile = create(:profile, faction: :guild, ducats: 20, abilities: [ "Mage (2)" ],
                                 keywords: [ "Leader", "Discipline (Blood Rites)" ])
      entry = Gang::Entry.new(list: list, entry: create(:card_reference, profile: profile), position: 1)
      entry.save(validate: false)
      pool = profile.profile_spell_pools.first
      entry.entry_pool_disciplines.create!(pool: pool, discipline: "blood_rites")
      Gang::EntrySpell.new(list_entry: entry, spell: spell, pool: pool).save!(validate: false)
      list.refresh_selection_validity
    end

    it "refreshes the validity of the gangs that chose it" do
      expect(list.reload.selection_valid).to be(true)

      spell.update!(discipline: :divinity)

      expect(list.reload.selection_valid).to be(false)
    end

    it "leaves them alone when only the text changes" do
      expect { spell.update!(description: "New text.") }.not_to(change { list.reload.updated_at })
    end
  end
end
