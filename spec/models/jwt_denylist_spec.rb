require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  # B-21: revoked tokens only need remembering until they'd expire on their own, so revoking a new
  # one opportunistically prunes the expired rows and the denylist doesn't grow without bound.
  describe ".revoke_jwt" do
    it "records the new token and drops rows whose token has already expired" do
      described_class.create!(jti: "expired", exp: 1.hour.ago)
      described_class.create!(jti: "still-valid", exp: 1.hour.from_now)

      described_class.revoke_jwt({ "jti" => "fresh", "exp" => 2.hours.from_now.to_i }, nil)

      expect(described_class.exists?(jti: "expired")).to be false
      expect(described_class.exists?(jti: "still-valid")).to be true
      expect(described_class.exists?(jti: "fresh")).to be true
    end
  end
end

# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti) UNIQUE
#
