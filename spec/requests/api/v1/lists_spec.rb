require 'rails_helper'

RSpec.describe "Api::V1::Lists", type: :request do
  let(:valid_params) { { list: { name: "My Gang", faction: "guild", points: 100 } } }
  let(:invalid_params) { { list: { name: "", faction: "guild", points: 100 } } }
  let(:headers) { { "Content-Type" => "application/json" } }

  describe "GET /api/v1/lists" do
    it "returns all lists" do
      create_list(:list, 3)
      get "/api/v1/lists"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it "returns the correct fields" do
      list = create(:list, name: "Test Gang", faction: "guild", points: 150)
      get "/api/v1/lists"
      body = JSON.parse(response.body).first
      expect(body).to include("id" => list.id, "name" => "Test Gang", "faction" => "guild", "points" => 150)
    end
  end

  describe "GET /api/v1/lists/:id" do
    it "returns the list with entries" do
      list = create(:list)
      ref = create(:reference, name: "Capodecina", cost: 20)
      create(:list_entry, list: list, reference: ref, position: 1)

      get "/api/v1/lists/#{list.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["entries"].size).to eq(1)
      expect(body["entries"].first).to include("position" => 1, "name" => "Capodecina", "cost" => 20)
    end

    it "returns entries ordered by position" do
      list = create(:list)
      ref_a = create(:reference)
      ref_b = create(:reference)
      create(:list_entry, list: list, reference: ref_b, position: 2)
      create(:list_entry, list: list, reference: ref_a, position: 1)

      get "/api/v1/lists/#{list.id}"
      positions = JSON.parse(response.body)["entries"].map { |e| e["position"] }
      expect(positions).to eq([1, 2])
    end

    it "returns 404 for unknown list" do
      get "/api/v1/lists/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/lists" do
    it "creates a list" do
      expect {
        post "/api/v1/lists", params: valid_params.to_json, headers: headers
      }.to change(List, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns the created list" do
      post "/api/v1/lists", params: valid_params.to_json, headers: headers
      body = JSON.parse(response.body)
      expect(body).to include("name" => "My Gang", "faction" => "guild", "points" => 100)
    end

    it "returns 422 with invalid params" do
      post "/api/v1/lists", params: invalid_params.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "PATCH /api/v1/lists/:id" do
    let(:list) { create(:list, name: "Old Name") }

    it "updates the list" do
      patch "/api/v1/lists/#{list.id}", params: { list: { name: "New Name" } }.to_json, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("New Name")
    end

    it "returns 422 with invalid params" do
      patch "/api/v1/lists/#{list.id}", params: invalid_params.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for unknown list" do
      patch "/api/v1/lists/99999", params: valid_params.to_json, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/lists/:id" do
    it "destroys the list" do
      list = create(:list)
      expect {
        delete "/api/v1/lists/#{list.id}"
      }.to change(List, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "also destroys associated entries" do
      list = create(:list)
      create(:list_entry, list: list)
      expect {
        delete "/api/v1/lists/#{list.id}"
      }.to change(ListEntry, :count).by(-1)
    end

    it "returns 404 for unknown list" do
      delete "/api/v1/lists/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
