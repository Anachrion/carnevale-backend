require 'rails_helper'

RSpec.describe CableTicket do
  let(:user) { create(:user) }

  describe ".issue! / .redeem" do
    it "issues a token that redeems to the user exactly once" do
      token = described_class.issue!(user)
      expect(token).to be_present

      expect(described_class.redeem(token)).to eq(user)
      # Single-use: the row is consumed on redemption, so a second attempt finds nothing.
      expect(described_class.redeem(token)).to be_nil
    end

    it "returns nil for an unknown or blank token" do
      expect(described_class.redeem("nope")).to be_nil
      expect(described_class.redeem(nil)).to be_nil
      expect(described_class.redeem("")).to be_nil
    end

    it "refuses an expired ticket and clears it out" do
      ticket = described_class.create!(user: user, token: "expired-token", expires_at: 1.minute.ago)

      expect(described_class.redeem("expired-token")).to be_nil
      expect(described_class.exists?(ticket.id)).to be false
    end

    it "lets one user hold several valid tickets at once (keyed per ticket, not per user)" do
      first = described_class.issue!(user)
      second = described_class.issue!(user)

      expect(first).not_to eq(second)
      expect(described_class.redeem(first)).to eq(user)
      expect(described_class.redeem(second)).to eq(user)
    end

    it "prunes already-expired rows when issuing a new ticket" do
      described_class.create!(user: user, token: "stale", expires_at: 1.minute.ago)

      described_class.issue!(user)

      expect(described_class.exists?(token: "stale")).to be false
    end
  end
end
