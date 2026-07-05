require 'rails_helper'

RSpec.describe "Api::V1::ListEntries", type: :request do
  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:list) { create(:list, owner: user, faction: :guild, points: 100) }
  let(:json_headers) { { "Content-Type" => "application/json" } }
  let(:headers) { auth_headers }

  def auth_headers(as: user)
    post "/api/v1/login", params: { user: { email: as.email, password: "password123" } }.to_json, headers: json_headers
    json_headers.merge("Authorization" => response.headers["Authorization"])
  end

  def guild_ref(cost: 10, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  def post_entry(ref, target_list: list, headers: self.headers)
    post "/api/v1/list_entries",
         params: { entry: { list_id: target_list.id, entry_type: ref.class.name, entry_id: ref.id } }.to_json,
         headers: headers
  end

  describe "POST /api/v1/list_entries" do
    it "creates an entry and returns the updated list" do
      post_entry(guild_ref(keywords: ["Leader"]))

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["entries"].size).to eq(1)
      expect(body["entries"].first["position"]).to eq(1)
    end

    it "assigns incrementing positions" do
      post_entry(guild_ref(keywords: ["Leader"]))
      post_entry(guild_ref)

      expect(response).to have_http_status(:created)
      positions = JSON.parse(response.body)["entries"].map { |e| e["position"] }
      expect(positions).to eq([1, 2])
    end

    it "creates the entry but marks the list's selection invalid when cost exceeds points limit" do
      post_entry(guild_ref(keywords: ["Leader"]))
      post_entry(guild_ref(cost: 101))

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["selection_valid"]).to be false
      expect(body["selection_errors"]).not_to be_empty
    end

    it "creates the entry but marks the list's selection invalid when card belongs to a different faction" do
      post_entry(guild_ref(keywords: ["Leader"]))
      profile = create(:profile, faction: :vatican, ducats: 10)
      ref = create(:card_reference, profile: profile)
      post_entry(ref)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["selection_valid"]).to be false
    end

    it "creates the entry but marks the list's selection invalid when adding a Unique card already present" do
      ref = guild_ref(keywords: ["Unique", "Leader"])
      create(:list_entry, list: list, entry: ref, position: 1)

      post_entry(ref)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["selection_valid"]).to be false
    end

    it "allows a gifted card in a non-gifted list" do
      leader_ref = guild_ref(keywords: ["Leader"])
      create(:list_entry, list: list, entry: leader_ref, position: 1)

      profile = create(:profile, faction: :gifted, ducats: 10)
      ref = create(:card_reference, profile: profile)
      post_entry(ref)

      expect(response).to have_http_status(:created)
    end
  end

  describe "PATCH /api/v1/list_entries/:id" do
    it "moves the entry to the requested position and returns the updated list" do
      ref_a = guild_ref(keywords: ["Leader"])
      ref_b = guild_ref
      ref_c = guild_ref
      e1 = create(:list_entry, list: list, entry: ref_a, position: 1)
      e2 = create(:list_entry, list: list, entry: ref_b, position: 2)
      e3 = create(:list_entry, list: list, entry: ref_c, position: 3)

      patch "/api/v1/list_entries/#{e3.id}",
            params: { entry: { position: 1 } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      positions = JSON.parse(response.body)["entries"].map { |e| e["position"] }
      expect(positions).to eq([1, 2, 3])
      expect(e3.reload.position).to eq(1)
      expect(e1.reload.position).to eq(2)
      expect(e2.reload.position).to eq(3)
    end

    it "does not auto-sort after a manual reorder" do
      leader_profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Leader"])
      henchman_profile = create(:profile, faction: :guild, ducats: 5, keywords: ["Henchman"])
      leader_ref = create(:card_reference, profile: leader_profile)
      henchman_ref = create(:card_reference, profile: henchman_profile)
      e2 = create(:list_entry, list: list, entry: leader_ref, position: 2)
      e1 = create(:list_entry, list: list, entry: henchman_ref, position: 1)

      patch "/api/v1/list_entries/#{e1.id}",
            params: { entry: { position: 2 } }.to_json,
            headers: headers

      expect(e1.reload.position).to eq(2)
      expect(e2.reload.position).to eq(1)
    end
  end

  describe "PATCH /api/v1/list_entries/:id/spells" do
    def mage_ref(cost: 20)
      profile = create(:profile, faction: :guild, ducats: cost,
                       abilities: ["Mage (2)", "Expert Sorcerer (1)"],
                       keywords: ["Leader", "Discipline (Blood Rites, Divinity)"])
      create(:card_reference, profile: profile)
    end

    def patch_spells(entry, discipline:, spell_ids:)
      patch "/api/v1/list_entries/#{entry.id}/spells",
            params: { entry: { discipline: discipline, spell_ids: spell_ids } }.to_json,
            headers: headers
    end

    it "sets the discipline and known spells, exposing them on the entry" do
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
      spells = create_list(:spell, 2, discipline: :blood_rites)

      patch_spells(entry, discipline: "blood_rites", spell_ids: spells.map(&:id))

      expect(response).to have_http_status(:ok)
      returned = JSON.parse(response.body)["entries"].first
      expect(returned["spell_discipline"]).to eq("blood_rites")
      expect(returned["spells"].map { |s| s["id"] }).to match_array(spells.map(&:id))
      expect(returned["mage"]).to be true
      expect(returned["spell_slots"]).to eq(3)
      expect(returned["cantrip"]).to be_nil
    end

    it "replaces a previous selection rather than appending" do
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
      first = create(:spell, discipline: :blood_rites)
      second = create(:spell, discipline: :divinity)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [first.id])
      patch_spells(entry, discipline: "divinity", spell_ids: [second.id])

      returned = JSON.parse(response.body)["entries"].first
      expect(returned["spells"].map { |s| s["id"] }).to eq([second.id])
    end

    it "saves an illegal selection but flips the list to invalid" do
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
      spells = create_list(:spell, 4, discipline: :blood_rites)

      patch_spells(entry, discipline: "blood_rites", spell_ids: spells.map(&:id))

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["selection_valid"]).to be false
      expect(body["selection_errors"]).to include(match(/too many spells/))
    end

    it "returns 404 when the entry belongs to another user" do
      other = create(:list, faction: :guild, points: 100)
      entry = create(:list_entry, list: other, entry: mage_ref, position: 1)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [])
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/list_entries/:id" do
    it "removes the entry and returns the updated list" do
      ref = guild_ref(keywords: ["Leader"])
      entry = create(:list_entry, list: list, entry: ref, position: 1)

      delete "/api/v1/list_entries/#{entry.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["entries"]).to be_empty
    end
  end

  describe "authorization" do
    let(:other_list) { create(:list, faction: :guild, points: 100) }

    it "returns 401 for POST when not authenticated" do
      post_entry(guild_ref, headers: json_headers.merge("Accept" => "application/json"))
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 when creating an entry on another user's list" do
      post_entry(guild_ref, target_list: other_list)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when updating another user's entry" do
      entry = create(:list_entry, list: other_list, entry: guild_ref, position: 1)

      patch "/api/v1/list_entries/#{entry.id}", params: { entry: { position: 1 } }.to_json, headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when destroying another user's entry" do
      entry = create(:list_entry, list: other_list, entry: guild_ref, position: 1)

      delete "/api/v1/list_entries/#{entry.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      expect(Gang::Entry.exists?(entry.id)).to be true
    end
  end
end
