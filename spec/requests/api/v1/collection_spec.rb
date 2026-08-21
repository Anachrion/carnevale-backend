require 'rails_helper'

RSpec.describe "Api::V1::Collection", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:json_headers) { { "Content-Type" => "application/json" } }
  let(:profile) { create(:profile, name: "Beggar") }
  let(:other_profile) { create(:profile, name: "Gondolier") }

  def auth_headers(as: user)
    post "/api/v1/login", params: { user: { email: as.email, password: "password123" } }.to_json, headers: json_headers
    json_headers.merge("Authorization" => response.headers["Authorization"])
  end

  def body = JSON.parse(response.body)

  describe "GET /api/v1/collection" do
    it "returns only the current player's rows" do
      create(:collection_item, user: user, profile: profile, owned: 3, built: 2, painted: 1)
      create(:collection_item, profile: other_profile, owned: 9)

      get "/api/v1/collection", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(body).to eq([ { "profile_id" => profile.id, "owned" => 3, "built" => 2, "painted" => 1 } ])
    end

    it "returns an empty collection rather than failing" do
      get "/api/v1/collection", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(body).to eq([])
    end

    it "returns 401 when not authenticated" do
      get "/api/v1/collection", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /api/v1/collection/:profile_id" do
    it "records a first miniature" do
      put "/api/v1/collection/#{profile.id}", params: { item: { owned: 2 } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(body).to eq({ "profile_id" => profile.id, "owned" => 2, "built" => 0, "painted" => 0 })
    end

    it "settles the other counts around the one it is sent" do
      create(:collection_item, user: user, profile: profile, owned: 1, built: 0, painted: 0)

      put "/api/v1/collection/#{profile.id}", params: { item: { painted: 1 } }.to_json, headers: auth_headers

      expect(body).to include("owned" => 1, "built" => 1, "painted" => 1)
    end

    it "drops the row and reports zeros once nothing is owned" do
      create(:collection_item, user: user, profile: profile, owned: 2, built: 2, painted: 2)

      expect {
        put "/api/v1/collection/#{profile.id}", params: { item: { owned: 0 } }.to_json, headers: auth_headers
      }.to change(Collection::Item, :count).by(-1)

      expect(body).to eq({ "profile_id" => profile.id, "owned" => 0, "built" => 0, "painted" => 0 })
    end

    it "rejects an unknown profile" do
      put "/api/v1/collection/0", params: { item: { owned: 1 } }.to_json, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(body["errors"]).to have_key("profile")
    end

    it "never touches another player's row" do
      theirs = create(:collection_item, profile: profile, owned: 9, built: 9, painted: 9)

      put "/api/v1/collection/#{profile.id}", params: { item: { owned: 1 } }.to_json, headers: auth_headers

      expect(theirs.reload.owned).to eq(9)
      expect(user.collection_items.sole.owned).to eq(1)
    end

    it "returns 401 when not authenticated" do
      put "/api/v1/collection/#{profile.id}", params: { item: { owned: 1 } }.to_json, headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "is idempotent: replaying the same write leaves the same state" do
      headers = auth_headers
      2.times do
        put "/api/v1/collection/#{profile.id}", params: { item: { owned: 2 } }.to_json, headers: headers
      end

      expect(Collection::Item.count).to eq(1)
      expect(body).to include("owned" => 2)
    end
  end

  describe "PUT /api/v1/collection" do
    it "applies several profiles at once" do
      put "/api/v1/collection",
          params: { items: [ { profile_id: profile.id, owned: 2 },
                             { profile_id: other_profile.id, owned: 1, built: 1, painted: 1 } ] }.to_json,
          headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(body).to contain_exactly(
        { "profile_id" => profile.id, "owned" => 2, "built" => 0, "painted" => 0 },
        { "profile_id" => other_profile.id, "owned" => 1, "built" => 1, "painted" => 1 }
      )
    end

    it "changes nothing at all when one entry names an unknown profile" do
      put "/api/v1/collection",
          params: { items: [ { profile_id: profile.id, owned: 2 },
                             { profile_id: 0, owned: 1 } ] }.to_json,
          headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Collection::Item.count).to eq(0)
    end

    it "returns 401 when not authenticated" do
      put "/api/v1/collection", params: { items: [] }.to_json, headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
