require 'rails_helper'

RSpec.describe "Api::V1::Lists", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:valid_params) { { list: { name: "My Gang", faction: "guild", points: 100 } } }
  let(:invalid_params) { { list: { name: "", faction: "guild", points: 100 } } }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  def auth_headers(as: user)
    post "/api/v1/login", params: { user: { email: as.email, password: "password123" } }.to_json, headers: json_headers
    json_headers.merge("Authorization" => response.headers["Authorization"])
  end

  describe "GET /api/v1/lists" do
    it "returns only the current user's lists" do
      create_list(:list, 3, owner: user)
      create(:list) # another user's list

      get "/api/v1/lists", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it "returns the correct fields including entries" do
      list = create(:list, owner: user, name: "Test Gang", faction: "guild", points: 150)
      ref = create(:card_reference, name: "Capodecina", profile: create(:profile, faction: "guild", ducats: 20, keywords: ["Leader"]))
      create(:list_entry, list: list, entry: ref, position: 1)

      get "/api/v1/lists", headers: auth_headers
      body = JSON.parse(response.body).first
      expect(body).to include("id" => list.id, "name" => "Test Gang", "faction" => "guild", "points" => 150)
      expect(body["entries"].first).to include("position" => 1, "name" => "Capodecina", "cost" => 20)
    end

    it "returns 401 when not authenticated" do
      get "/api/v1/lists", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/lists/:id" do
    it "returns the list with entries" do
      list = create(:list, owner: user)
      ref = create(:card_reference, name: "Capodecina", profile: create(:profile, faction: "guild", ducats: 20, keywords: ["Leader"]))
      create(:list_entry, list: list, entry: ref, position: 1)

      get "/api/v1/lists/#{list.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["entries"].size).to eq(1)
      expect(body["entries"].first).to include("position" => 1, "name" => "Capodecina", "cost" => 20)
    end

    it "returns entries ordered by position" do
      list = create(:list, owner: user)
      ref_a = create(:card_reference)
      ref_b = create(:card_reference, profile: create(:profile, faction: "guild", keywords: ["Leader"]))
      create(:list_entry, list: list, entry: ref_b, position: 2)
      create(:list_entry, list: list, entry: ref_a, position: 1)

      get "/api/v1/lists/#{list.id}", headers: auth_headers
      positions = JSON.parse(response.body)["entries"].map { |e| e["position"] }
      expect(positions).to eq([1, 2])
    end

    it "returns 404 for unknown list" do
      get "/api/v1/lists/99999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for another user's list" do
      list = create(:list)
      get "/api/v1/lists/#{list.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/lists" do
    it "creates a list owned by the current user" do
      expect {
        post "/api/v1/lists", params: valid_params.to_json, headers: auth_headers
      }.to change(List, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(List.last.owner).to eq(user)
    end

    it "returns the created list" do
      post "/api/v1/lists", params: valid_params.to_json, headers: auth_headers
      body = JSON.parse(response.body)
      expect(body).to include("name" => "My Gang", "faction" => "guild", "points" => 100)
    end

    it "returns 422 with invalid params" do
      post "/api/v1/lists", params: invalid_params.to_json, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "returns 401 when not authenticated" do
      post "/api/v1/lists", params: valid_params.to_json, headers: json_headers.merge("Accept" => "application/json")
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/lists/:id" do
    let(:list) { create(:list, owner: user, name: "Old Name") }

    it "updates the list" do
      patch "/api/v1/lists/#{list.id}", params: { list: { name: "New Name" } }.to_json, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("New Name")
    end

    it "returns 422 with invalid params" do
      patch "/api/v1/lists/#{list.id}", params: invalid_params.to_json, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for unknown list" do
      patch "/api/v1/lists/99999", params: valid_params.to_json, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 and does not update another user's list" do
      other_list = create(:list, name: "Not Yours")
      patch "/api/v1/lists/#{other_list.id}", params: { list: { name: "Hijacked" } }.to_json, headers: auth_headers
      expect(response).to have_http_status(:not_found)
      expect(other_list.reload.name).to eq("Not Yours")
    end
  end

  describe "DELETE /api/v1/lists/:id" do
    it "destroys the list" do
      list = create(:list, owner: user)
      expect {
        delete "/api/v1/lists/#{list.id}", headers: auth_headers
      }.to change(List, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "also destroys associated entries" do
      list = create(:list, owner: user)
      create(:list_entry, list: list, entry: create(:card_reference, profile: create(:profile, faction: "guild", keywords: ["Leader"])))
      expect {
        delete "/api/v1/lists/#{list.id}", headers: auth_headers
      }.to change(ListEntry, :count).by(-1)
    end

    it "returns 404 for unknown list" do
      delete "/api/v1/lists/99999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 and does not destroy another user's list" do
      other_list = create(:list)
      expect {
        delete "/api/v1/lists/#{other_list.id}", headers: auth_headers
      }.not_to change(List, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
