require 'rails_helper'

RSpec.describe "Api::V1::Passwords", type: :request do
  let(:headers) { { "Content-Type" => "application/json" } }
  let!(:user) { create(:user, email: "reset@example.com") }

  describe "POST /api/v1/password" do
    it "sends reset instructions for a known email" do
      expect {
        post "/api/v1/password", params: { user: { email: user.email } }.to_json, headers: headers
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to have_http_status(:ok)
      expect(user.reload.reset_password_token).to be_present
    end

    it "returns 422 for an unknown email" do
      post "/api/v1/password", params: { user: { email: "nobody@example.com" } }.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to have_key("email")
    end
  end

  describe "PATCH /api/v1/password" do
    it "resets the password with a valid token" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(user.reload.valid_password?("NewSecret123!")).to be true
    end

    it "returns 422 for an invalid token" do
      patch "/api/v1/password",
            params: { user: { reset_password_token: "bogus", password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to have_key("reset_password_token")
    end

    it "returns 422 when the confirmation does not match" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "Mismatch123!" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
