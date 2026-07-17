require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  let(:user) { create(:user) }

  describe ".issue!" do
    it "returns an opaque token and stores only its digest" do
      raw = described_class.issue!(user)

      expect(raw).to be_present
      record = described_class.sole
      expect(record.token_digest).to eq(described_class.digest(raw))
      expect(record.token_digest).not_to eq(raw)
      expect(record.expires_at).to be_within(1.minute).of(described_class::TTL.from_now)
    end

    it "prunes already-expired tokens so the table can't grow unbounded" do
      described_class.create!(user: user, token_digest: "stale", expires_at: 1.day.ago)

      described_class.issue!(user)

      expect(described_class.where(token_digest: "stale")).to be_empty
    end
  end

  describe ".rotate" do
    it "redeems a valid token, returning the user and a fresh token" do
      raw = described_class.issue!(user)

      result = described_class.rotate(raw)

      expect(result[:user]).to eq(user)
      expect(result[:token]).to be_present
      expect(result[:token]).not_to eq(raw)
    end

    it "invalidates the presented token (single use)" do
      raw = described_class.issue!(user)

      described_class.rotate(raw)

      expect(described_class.rotate(raw)).to be_nil
      expect(described_class.where(token_digest: described_class.digest(raw))).to be_empty
    end

    it "returns nil and consumes the row for an expired token" do
      raw = described_class.issue!(user)
      described_class.sole.update!(expires_at: 1.second.ago)

      expect(described_class.rotate(raw)).to be_nil
      expect(described_class.count).to eq(0)
    end

    it "returns nil for an unknown or blank token without issuing anything" do
      expect(described_class.rotate("nope")).to be_nil
      expect(described_class.rotate("")).to be_nil
      expect(described_class.rotate(nil)).to be_nil
      expect(described_class.count).to eq(0)
    end
  end

  describe ".revoke_all_for" do
    it "drops every token the user holds but leaves other users' tokens" do
      other = create(:user)
      described_class.issue!(user)
      described_class.issue!(user)
      described_class.issue!(other)

      described_class.revoke_all_for(user)

      expect(described_class.where(user: user)).to be_empty
      expect(described_class.where(user: other).count).to eq(1)
    end
  end
end

# == Schema Information
#
# Table name: refresh_tokens
#
#  id           :bigint           not null, primary key
#  expires_at   :datetime         not null
#  token_digest :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_refresh_tokens_on_expires_at    (expires_at)
#  index_refresh_tokens_on_token_digest  (token_digest) UNIQUE
#  index_refresh_tokens_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
