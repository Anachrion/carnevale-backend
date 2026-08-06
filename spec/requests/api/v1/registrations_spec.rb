require 'rails_helper'

RSpec.describe "Api::V1::Registrations", type: :request do
  let(:headers) { { "Content-Type" => "application/json" } }

  describe "POST /api/v1/signup" do
    it "creates a user" do
      params = { user: { username: "newuser", email: "newuser@example.com", password: "password123", password_confirmation: "password123" } }

      expect {
        post "/api/v1/signup", params: params.to_json, headers: headers
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    # CARNEVALEB-73: this endpoint is documented as returning `Account` — the created user and
    # nothing else. It was previously documented as a `Session`, and the generated Dart client
    # (whose `refresh_token` is non-nullable) then threw on every *successful* registration and
    # reported it to the user as a failure, with the account already created. Asserting only the
    # status code is what let that divergence through, so pin the body's shape here.
    it "returns the created account and no credentials" do
      params = { user: { username: "newuser", email: "newuser@example.com", password: "password123", password_confirmation: "password123" } }

      post "/api/v1/signup", params: params.to_json, headers: headers

      body = JSON.parse(response.body)
      expect(body.keys).to contain_exactly("user")
      expect(body["user"]).to eq(
        "id" => User.last.id, "email" => "newuser@example.com", "username" => "newuser"
      )
      # Registering doesn't sign anyone in: no JWT in the header, no refresh token in the body.
      expect(response.headers["Authorization"]).to be_nil
    end

    it "returns 422 with invalid params" do
      params = { user: { username: "", email: "bad", password: "short", password_confirmation: "mismatch" } }
      post "/api/v1/signup", params: params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/account" do
    let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

    def auth_headers
      post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }.to_json, headers: headers
      headers.merge("Authorization" => response.headers["Authorization"])
    end

    it "updates the username when authenticated" do
      patch "/api/v1/account", params: { user: { username: "renamed" } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["user"]).to include("username" => "renamed")
      expect(user.reload.username).to eq("renamed")
    end

    it "returns 401 when not authenticated" do
      patch "/api/v1/account",
            params: { user: { username: "renamed" } }.to_json,
            headers: headers.merge("Accept" => "application/json")

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 422 for a blank username" do
      patch "/api/v1/account", params: { user: { username: "" } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when the username is already taken" do
      create(:user, username: "taken")
      patch "/api/v1/account", params: { user: { username: "taken" } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "ignores an attempt to also change the password through this endpoint" do
      patch "/api/v1/account", params: { user: { username: "renamed2", password: "hacked123" } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(user.reload.valid_password?("password123")).to be true
    end
  end
end
