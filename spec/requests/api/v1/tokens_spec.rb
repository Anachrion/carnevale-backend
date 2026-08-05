require 'rails_helper'

RSpec.describe "Api::V1::Tokens", type: :request do
  let(:user) { create(:user) }
  let(:json_headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

  def log_in
    post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }.to_json, headers: json_headers
    JSON.parse(response.body)
  end

  describe "POST /api/v1/login" do
    it "returns a refresh token alongside the JWT header" do
      body = log_in

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer /)
      expect(body["refresh_token"]).to be_present
    end
  end

  describe "POST /api/v1/token" do
    it "trades a refresh token for a fresh JWT and a rotated refresh token" do
      refresh = log_in["refresh_token"]

      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer /)
      body = JSON.parse(response.body)
      expect(body.dig("user", "id")).to eq(user.id)
      expect(body["refresh_token"]).to be_present
      expect(body["refresh_token"]).not_to eq(refresh)
    end

    it "the fresh JWT actually authenticates a protected endpoint" do
      refresh = log_in["refresh_token"]
      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: json_headers
      jwt = response.headers["Authorization"]

      post "/api/v1/cable_tickets", headers: json_headers.merge("Authorization" => jwt)

      expect(response).to have_http_status(:created)
    end

    it "rejects a refresh token that was already rotated once" do
      refresh = log_in["refresh_token"]
      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: json_headers

      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an unknown refresh token" do
      post "/api/v1/token", params: { refresh_token: "nonsense" }.to_json, headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/logout" do
    it "revokes the refresh token so it can no longer be redeemed" do
      body = log_in
      jwt = response.headers["Authorization"]
      refresh = body["refresh_token"]

      delete "/api/v1/logout", headers: json_headers.merge("Authorization" => jwt)
      expect(response).to have_http_status(:no_content)

      post "/api/v1/token", params: { refresh_token: refresh }.to_json, headers: json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "signs out only the device that presented its token" do
      phone = log_in["refresh_token"]
      laptop = log_in["refresh_token"]
      laptop_jwt = response.headers["Authorization"]

      delete "/api/v1/logout",
             params: { refresh_token: laptop }.to_json,
             headers: json_headers.merge("Authorization" => laptop_jwt)
      expect(response).to have_http_status(:no_content)

      post "/api/v1/token", params: { refresh_token: laptop }.to_json, headers: json_headers
      expect(response).to have_http_status(:unauthorized)

      # The regression this guards: the phone had nothing to do with the laptop's logout, and used
      # to be signed out by it — silently, hours later, when its own access JWT expired.
      post "/api/v1/token", params: { refresh_token: phone }.to_json, headers: json_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/logout_all" do
    it "revokes every device's refresh token" do
      phone = log_in["refresh_token"]
      laptop = log_in["refresh_token"]
      laptop_jwt = response.headers["Authorization"]

      delete "/api/v1/logout_all", headers: json_headers.merge("Authorization" => laptop_jwt)
      expect(response).to have_http_status(:no_content)

      [ phone, laptop ].each do |raw|
        post "/api/v1/token", params: { refresh_token: raw }.to_json, headers: json_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
