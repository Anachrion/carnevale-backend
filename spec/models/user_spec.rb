require 'rails_helper'

RSpec.describe User, type: :model do
  describe ".find_for_database_authentication" do
    let!(:user) { create(:user, email: "Player@Example.com", username: "PlayerOne") }

    it "finds the user by email" do
      expect(described_class.find_for_database_authentication(email: "Player@Example.com")).to eq(user)
    end

    it "finds the user by email case-insensitively" do
      expect(described_class.find_for_database_authentication(email: "player@example.com")).to eq(user)
    end

    it "finds the user by username" do
      expect(described_class.find_for_database_authentication(email: "PlayerOne")).to eq(user)
    end

    it "finds the user by username case-insensitively" do
      expect(described_class.find_for_database_authentication(email: "playerone")).to eq(user)
    end

    it "returns nil when neither matches" do
      expect(described_class.find_for_database_authentication(email: "nobody")).to be_nil
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
