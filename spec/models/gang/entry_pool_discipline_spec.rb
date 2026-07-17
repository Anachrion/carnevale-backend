require "rails_helper"

RSpec.describe Gang::EntryPoolDiscipline, type: :model do
  # A committed Discipline must be a real one (moved here from Gang::Entry#spell_discipline when
  # spell selection became per-pool, CARNEVALEB-47). A mis-cased or bogus value ("Blood Rites"
  # instead of "blood_rites") should be rejected rather than saved silently (B-28).
  it "accepts a real Discipline but not a bogus one" do
    list = create(:list, faction: :guild, points: 100)
    profile = create(:profile, faction: :guild, ducats: 20,
                     abilities: [ "Mage (2)" ], keywords: [ "Discipline (Blood Rites)" ])
    ref = create(:card_reference, profile: profile)
    entry = create(:list_entry, list: list, entry: ref, position: 1)
    pool = profile.profile_spell_pools.first

    valid = entry.entry_pool_disciplines.build(pool: pool, discipline: "blood_rites")
    expect(valid).to be_valid

    bogus = entry.entry_pool_disciplines.build(pool: pool, discipline: "Blood Rites")
    expect(bogus).not_to be_valid
    expect(bogus.errors[:discipline]).to be_present
  end
end

# == Schema Information
#
# Table name: entry_pool_disciplines
#
#  id            :bigint           not null, primary key
#  discipline    :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_entry_id :bigint           not null
#  pool_id       :bigint           not null
#
# Indexes
#
#  index_entry_pool_disciplines_on_list_entry_id  (list_entry_id)
#  index_entry_pool_disciplines_on_pool_id        (pool_id)
#  index_entry_pool_disciplines_uniqueness        (list_entry_id,pool_id,discipline) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#  fk_rails_...  (pool_id => profile_spell_pools.id) ON DELETE => cascade
#
