require 'rails_helper'

RSpec.describe Catalog::Profile, type: :model do
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
#  dexterity                    :integer          default(0), not null
#  distinct_discipline_per_copy :boolean          default(FALSE), not null
#  ducats                       :integer          default(0), not null
#  faction                      :string           default(NULL), not null
#  flexible_leader              :boolean          default(FALSE), not null
#  keywords                     :json             not null
#  life_points                  :integer          default(0), not null
#  mind                         :integer          default(0), not null
#  movement                     :integer          default(0), not null
#  name                         :string           default(""), not null
#  protection                   :integer          default(0), not null
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
