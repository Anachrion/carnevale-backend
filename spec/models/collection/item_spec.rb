require 'rails_helper'

RSpec.describe Collection::Item, type: :model do
  let(:user) { create(:user) }
  let(:profile) { create(:profile) }

  def counts_of(item) = [ item.owned, item.built, item.painted ]

  describe "normalisation" do
    it "pulls the wider counts up when a narrower one is raised" do
      item = create(:collection_item, user: user, profile: profile, owned: 1, built: 0, painted: 0)

      item.update!(painted: 1)

      expect(counts_of(item)).to eq([ 1, 1, 1 ])
    end

    it "pushes the narrower counts down when a wider one is lowered" do
      item = create(:collection_item, user: user, profile: profile, owned: 3, built: 3, painted: 2)

      item.update!(owned: 1)

      expect(counts_of(item)).to eq([ 1, 1, 1 ])
    end

    it "lowers painted with built, leaving owned alone" do
      item = create(:collection_item, user: user, profile: profile, owned: 3, built: 3, painted: 3)

      item.update!(built: 1)

      expect(counts_of(item)).to eq([ 3, 1, 1 ])
    end

    it "provisions the counts a first painted miniature implies" do
      item = described_class.create!(user: user, profile: profile, painted: 1)

      expect(counts_of(item)).to eq([ 1, 1, 1 ])
    end

    it "floors negative counts at zero" do
      item = described_class.create!(user: user, profile: profile, owned: 2, built: -5, painted: -1)

      expect(counts_of(item)).to eq([ 2, 0, 0 ])
    end

    it "never stores counts the check constraint would reject" do
      item = create(:collection_item, user: user, profile: profile, owned: 4, built: 4, painted: 4)

      expect { item.update!(owned: 2) }.not_to raise_error
      expect(item.reload).to have_attributes(owned: 2, built: 2, painted: 2)
    end
  end

  describe ".set!" do
    it "creates the row on a first write" do
      expect {
        described_class.set!(user: user, profile_id: profile.id, counts: { owned: 2 })
      }.to change(described_class, :count).by(1)
    end

    it "updates the row in place on a later write" do
      described_class.set!(user: user, profile_id: profile.id, counts: { owned: 2 })

      expect {
        described_class.set!(user: user, profile_id: profile.id, counts: { owned: 3 })
      }.not_to change(described_class, :count)

      expect(user.collection_items.sole.owned).to eq(3)
    end

    it "settles the other counts around the one it is given" do
      described_class.set!(user: user, profile_id: profile.id, counts: { owned: 3, built: 3, painted: 3 })
      item = described_class.set!(user: user, profile_id: profile.id, counts: { built: 1 })

      expect(counts_of(item)).to eq([ 3, 1, 1 ])
    end

    it "destroys the row once every count is back to zero" do
      described_class.set!(user: user, profile_id: profile.id, counts: { owned: 2 })

      expect {
        described_class.set!(user: user, profile_id: profile.id, counts: { owned: 0 })
      }.to change(described_class, :count).by(-1)
    end

    it "does not create a row for counts that are all zero" do
      expect {
        described_class.set!(user: user, profile_id: profile.id, counts: { owned: 0 })
      }.not_to change(described_class, :count)
    end

    it "still reports the resulting counts after destroying the row" do
      described_class.set!(user: user, profile_id: profile.id, counts: { owned: 2 })
      item = described_class.set!(user: user, profile_id: profile.id, counts: { owned: 0 })

      expect(counts_of(item)).to eq([ 0, 0, 0 ])
    end

    it "raises when the profile does not exist" do
      expect {
        described_class.set!(user: user, profile_id: -1, counts: { owned: 1 })
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "keeps two players' collections apart" do
      other = create(:user)
      described_class.set!(user: user, profile_id: profile.id, counts: { owned: 2 })
      described_class.set!(user: other, profile_id: profile.id, counts: { owned: 5 })

      expect(user.collection_items.sole.owned).to eq(2)
      expect(other.collection_items.sole.owned).to eq(5)
    end
  end

  it "allows only one row per player and profile" do
    create(:collection_item, user: user, profile: profile)

    duplicate = build(:collection_item, user: user, profile: profile)

    expect(duplicate).not_to be_valid
  end
end

# == Schema Information
#
# Table name: collection_items
#
#  id         :bigint           not null, primary key
#  built      :integer          default(0), not null
#  owned      :integer          default(0), not null
#  painted    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_collection_items_on_profile_id              (profile_id)
#  index_collection_items_on_user_id_and_profile_id  (user_id,profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (user_id => users.id)
#
