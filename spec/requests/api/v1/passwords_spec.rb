require 'rails_helper'

RSpec.describe "Api::V1::Passwords", type: :request do
  include ActiveJob::TestHelper

  let(:headers) { { "Content-Type" => "application/json" } }
  let!(:user) { create(:user, email: "reset@example.com") }

  describe "POST /api/v1/password" do
    # Devise now delivers the reset email via deliver_later, so the mail lands on the queue rather
    # than in ActionMailer::Base.deliveries until the enqueued job runs.
    it "sends reset instructions for a known email" do
      expect {
        perform_enqueued_jobs do
          post "/api/v1/password", params: { user: { email: user.email } }.to_json, headers: headers
        end
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to have_http_status(:ok)
      expect(user.reload.reset_password_token).to be_present
    end

    # B-20: with Devise paranoid mode, an unknown email must be indistinguishable from a known one —
    # same 200, no mail — so the endpoint can't be used to enumerate which addresses have accounts.
    it "does not reveal whether an unknown email has an account" do
      expect {
        post "/api/v1/password", params: { user: { email: "nobody@example.com" } }.to_json, headers: headers
      }.not_to change { ActionMailer::Base.deliveries.size }

      expect(response).to have_http_status(:ok)
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

    # The response must be a full Session (JWT header + refresh_token + user), the shape
    # doc/openapi.yaml has always declared for this endpoint and the generated client deserializes
    # into. It previously returned `user` alone, so every *successful* reset blew up in the client
    # on a missing non-nullable `refresh_token` and surfaced as a generic failure — the user then
    # retried and hit "token is invalid", because the first attempt had in fact worked.
    it "signs the user in, returning a JWT and a refresh token" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer /)

      body = JSON.parse(response.body)
      expect(body["refresh_token"]).to be_present
      expect(body.dig("user", "id")).to eq(user.id)
    end

    # The refresh token handed out here has to be a working one, or the client would be signed in
    # for exactly one hour and then be unable to renew.
    it "returns a refresh token that can be exchanged for a fresh JWT" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers
      refresh = JSON.parse(response.body)["refresh_token"]

      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer /)
    end

    # A reset is how you lock someone out who knew your old password. If the refresh tokens issued
    # under it survived, they would not be locked out at all — they'd keep renewing for 30 days.
    it "revokes refresh tokens issued before the reset" do
      old_token = RefreshToken.issue!(user)
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers
      expect(response).to have_http_status(:ok)

      post "/api/v1/token", params: { refresh_token: old_token }.to_json, headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    # ...but the token handed to the caller who just completed the reset must survive it, or they
    # would be signed out by their own password change.
    it "keeps the refresh token it hands back" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers
      refresh = JSON.parse(response.body)["refresh_token"]

      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: headers
      expect(response).to have_http_status(:ok)
    end

    # Signing in must not also open a Devise session: a cookie here would be replayed by a
    # browser-based client onto HTML requests and sign the app user into the backoffice scope.
    it "does not set a session cookie" do
      raw_token = user.send_reset_password_instructions

      patch "/api/v1/password",
            params: { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json,
            headers: headers

      expect(response.headers["Set-Cookie"]).to be_blank
    end

    # Single-use: the replay that produced the confusing "token is invalid" report must keep
    # answering 422 rather than minting a second session off a spent token.
    it "rejects a token that has already been used" do
      raw_token = user.send_reset_password_instructions
      params = { user: { reset_password_token: raw_token, password: "NewSecret123!", password_confirmation: "NewSecret123!" } }.to_json

      patch "/api/v1/password", params: params, headers: headers
      expect(response).to have_http_status(:ok)

      patch "/api/v1/password", params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to have_key("reset_password_token")
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
