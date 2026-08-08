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

    it "renders in a constant number of queries regardless of entry count (no N+1)" do
      headers = auth_headers # authenticate first, so login isn't part of the measured block

      small = create(:list, owner: user)
      3.times { |i| create(:list_entry, list: small, entry: create(:card_reference, profile: create(:profile, faction: "guild")), position: i + 1) }
      large = create(:list, owner: user)
      8.times { |i| create(:list_entry, list: large, entry: create(:card_reference, profile: create(:profile, faction: "guild")), position: i + 1) }

      small_queries = count_queries { get "/api/v1/lists/#{small.id}", headers: headers }
      large_queries = count_queries { get "/api/v1/lists/#{large.id}", headers: headers }

      # A profile N+1 would make the 8-entry list issue 5 more queries than the 3-entry one.
      expect(large_queries).to eq(small_queries)
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
      }.to change(Gang::List, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(Gang::List.last.owner).to eq(user)
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
      }.to change(Gang::List, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "also destroys associated entries" do
      list = create(:list, owner: user)
      create(:list_entry, list: list, entry: create(:card_reference, profile: create(:profile, faction: "guild", keywords: ["Leader"])))
      expect {
        delete "/api/v1/lists/#{list.id}", headers: auth_headers
      }.to change(Gang::Entry, :count).by(-1)
    end

    it "returns 404 for unknown list" do
      delete "/api/v1/lists/99999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 and does not destroy another user's list" do
      other_list = create(:list)
      expect {
        delete "/api/v1/lists/#{other_list.id}", headers: auth_headers
      }.not_to change(Gang::List, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
  describe "the plain-text gang exchange (CARNEVALEB-74)" do
    def model!(name)
      profile = create(:profile, name: name, faction: "guild")
      create(:card_reference, profile: profile, identifier: "guild-#{name.parameterize}-a")
      profile
    end

    describe "GET /api/v1/lists/:id/export" do
      it "returns the gang as text" do
        model!("Bravo")
        list = create(:list, owner: user, name: "Blood of the Lamb", faction: "guild", points: 150)
        create(:list_entry, list: list, entry: Catalog::Profile.find_by(name: "Bravo").card_references.first, position: 1)

        get "/api/v1/lists/#{list.id}/export", headers: auth_headers

        expect(response).to have_http_status(:ok)
        text = JSON.parse(response.body)["text"]
        expect(text).to include("Carnevale gang: Blood of the Lamb", "Faction: guild", "- Bravo")
      end

      # Lists are scoped to their owner everywhere else; export must not become the one way to read
      # somebody else's gang.
      it "404s on another user's list" do
        get "/api/v1/lists/#{create(:list).id}/export", headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end

      it "401s without a session" do
        get "/api/v1/lists/#{create(:list, owner: user).id}/export", headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "POST /api/v1/lists/import" do
      let(:text) { "Carnevale gang: Imported\nFaction: guild\nDucats: 150\n\nModels\n- Bravo\n" }

      it "creates a new list owned by the caller" do
        model!("Bravo")

        expect {
          post "/api/v1/lists/import", params: { text: text }.to_json, headers: auth_headers
        }.to change(user.lists, :count).by(1)

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["list"]).to include("name" => "Imported", "faction" => "guild")
        expect(body["list"]["entries"].map { |e| e["profile_name"] }).to eq([ "Bravo" ])
        expect(body["warnings"]).to eq([])
      end

      # The contract that keeps one typo from costing a whole gang: partial success, reported.
      it "reports what it could not resolve and still creates the rest" do
        model!("Bravo")

        post "/api/v1/lists/import",
             params: { text: text.sub("- Bravo", "- Bravo\n- Nonesuch") }.to_json,
             headers: auth_headers

        body = JSON.parse(response.body)
        expect(body["list"]["entries"].size).to eq(1)
        expect(body["warnings"]).to include(a_string_matching(/Nonesuch/))
      end

      it "401s without a session" do
        post "/api/v1/lists/import", params: { text: text }.to_json, headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
