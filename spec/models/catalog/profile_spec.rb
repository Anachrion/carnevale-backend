require 'rails_helper'

RSpec.describe Catalog::Profile, type: :model do
  # Players' spell picks point at a pool with ON DELETE CASCADE, so replacing the pools must not
  # recreate them: that wiped every gang's known spells on each backoffice save (CARNEVALEB-84).
  describe "#replace_spell_pools!" do
    let(:profile) { create(:profile, faction: :guild, abilities: [ "Mage (2)" ], keywords: [ "Leader", "Discipline (Fateweaving)" ]) }
    let(:spell) { create(:spell, discipline: :fateweaving) }
    let!(:entry) do
      list = create(:list, faction: :guild, points: 100)
      Gang::Entry.new(list: list, entry: create(:card_reference, profile: profile), position: 1).tap { |e| e.save(validate: false) }
    end

    def pick!(pool)
      entry.entry_pool_disciplines.create!(pool: pool, discipline: "fateweaving")
      Gang::EntrySpell.new(list_entry: entry, spell: spell, pool: pool).save!(validate: false)
    end

    it "keeps the players' picks when the pools are saved again, changed or not" do
      pool = profile.profile_spell_pools.sole
      pick!(pool)

      profile.replace_spell_pools!([ { of: 1, slot_count: 3, mage_slot_count: 2, disciplines: %w[fateweaving wild_magic] } ])

      expect(profile.profile_spell_pools.sole.id).to eq(pool.id)
      expect(profile.profile_spell_pools.sole).to have_attributes(slot_count: 3, disciplines: %w[fateweaving wild_magic])
      expect(entry.entry_spells.count).to eq(1)
      expect(entry.entry_pool_disciplines.count).to eq(1)
    end

    it "adds pools after the existing ones and removes only the pools dropped from the list" do
      first = profile.profile_spell_pools.sole
      pick!(first)
      profile.replace_spell_pools!([ { of: 1, slot_count: 2, disciplines: %w[fateweaving] },
                                     { of: 1, slot_count: 1, disciplines: %w[divinity] } ])
      second = profile.profile_spell_pools.order(:position).last
      Gang::EntrySpell.new(list_entry: entry, spell: create(:spell, discipline: :divinity), pool: second).save!(validate: false)

      profile.replace_spell_pools!([ { of: 1, slot_count: 2, disciplines: %w[fateweaving] } ])

      expect(profile.profile_spell_pools.pluck(:id)).to eq([ first.id ])
      expect(entry.entry_spells.pluck(:pool_id)).to eq([ first.id ])
    end
  end

  describe "#refresh_dependent_list_validity!" do
    # B-24: editing a profile in the backoffice touches no gang's own row, so a gang that hired it
    # keeps its stale cached validity until the owner next edits the list. This recomputes it now.
    it "recomputes the cached validity of gangs that hired the profile" do
      list = create(:list, faction: :guild, points: 100)
      profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Leader"])
      ref = create(:card_reference, profile: profile)
      create(:list_entry, list: list, entry: ref, position: 1)
      expect(list.reload.selection_valid).to be true

      # A rebalance pushes the model over the gang's budget. Nothing has refreshed the gang yet, so
      # its cached flag is now stale-true...
      profile.update!(ducats: 200)
      expect(list.reload.selection_valid).to be true

      # ...until we recompute the dependents.
      profile.refresh_dependent_list_validity!

      expect(list.reload.selection_valid).to be false
      expect(list.selection_errors).to include(match(/exceeds the 100 points limit/))
    end

    it "leaves gangs that never hired the profile untouched" do
      other_list = create(:list, faction: :guild, points: 100)
      create(:list_entry, list: other_list,
             entry: create(:card_reference, profile: create(:profile, faction: :guild, ducats: 10, keywords: ["Leader"])),
             position: 1)
      expect(other_list.reload.selection_valid).to be true

      unrelated = create(:profile, faction: :guild, ducats: 999)
      create(:card_reference, profile: unrelated)

      expect { unrelated.refresh_dependent_list_validity! }
        .not_to change { other_list.reload.selection_valid }
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                           :bigint           not null, primary key
#  abilities                    :json             not null
#  action_points                :integer          default(0), not null
#  attack                       :integer          default(0), not null
#  command_points               :integer          default(0), not null
#  companion_upgrade_ducats     :integer          default(0), not null
#  dexterity                    :integer          default(0), not null
#  distinct_discipline_per_copy :boolean          default(FALSE), not null
#  ducats                       :integer          default(0), not null
#  exclusive_weapons            :boolean          default(FALSE), not null
#  faction                      :string           not null
#  flexible_leader              :boolean          default(FALSE), not null
#  keywords                     :json             not null
#  life_points                  :integer          default(0), not null
#  mind                         :integer          default(0), not null
#  movement                     :integer          default(0), not null
#  name                         :string           default(""), not null
#  protection                   :integer          default(0), not null
#  recruitable                  :boolean          default(TRUE), not null
#  size                         :integer          default(0), not null
#  version                      :string           default("2.2.0"), not null
#  will_points                  :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  flexible_leader_with_id      :bigint
#
# Indexes
#
#  index_profiles_on_flexible_leader_with_id  (flexible_leader_with_id)
#
# Foreign Keys
#
#  fk_rails_...  (flexible_leader_with_id => profiles.id)
#
