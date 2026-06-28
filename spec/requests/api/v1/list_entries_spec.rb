require 'rails_helper'

RSpec.describe "Api::V1::ListEntries", type: :request do
  let(:list) { create(:list, faction: :guild, points: 100) }
  let(:headers) { { "Content-Type" => "application/json" } }

  def guild_ref(cost: 10, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  def post_entry(ref, target_list: list)
    post "/api/v1/list_entries",
         params: { entry: { list_id: target_list.id, card_reference_id: ref.id } }.to_json,
         headers: headers
  end

  describe "POST /api/v1/list_entries" do
    it "creates an entry and returns the updated list" do
      post_entry(guild_ref)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["entries"].size).to eq(1)
      expect(body["entries"].first["position"]).to eq(1)
    end

    it "assigns incrementing positions" do
      post_entry(guild_ref)
      post_entry(guild_ref)

      expect(response).to have_http_status(:created)
      positions = JSON.parse(response.body)["entries"].map { |e| e["position"] }
      expect(positions).to eq([1, 2])
    end

    it "returns 422 when cost exceeds points limit" do
      post_entry(guild_ref(cost: 101))

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).not_to be_empty
    end

    it "returns 422 when card belongs to a different faction" do
      profile = create(:profile, faction: :vatican, ducats: 10)
      ref = create(:card_reference, profile: profile)
      post_entry(ref)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 422 when adding a Unique card already present" do
      ref = guild_ref(keywords: ["Unique"])
      create(:list_entry, list: list, card_reference: ref, position: 1)

      post_entry(ref)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows a gifted card in a non-gifted list" do
      profile = create(:profile, faction: :gifted, ducats: 10)
      ref = create(:card_reference, profile: profile)
      post_entry(ref)

      expect(response).to have_http_status(:created)
    end
  end

  describe "PATCH /api/v1/list_entries/:id" do
    it "moves the entry to the requested position and returns the updated list" do
      ref_a = guild_ref
      ref_b = guild_ref
      ref_c = guild_ref
      e1 = create(:list_entry, list: list, card_reference: ref_a, position: 1)
      e2 = create(:list_entry, list: list, card_reference: ref_b, position: 2)
      e3 = create(:list_entry, list: list, card_reference: ref_c, position: 3)

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
      e1 = create(:list_entry, list: list, card_reference: henchman_ref, position: 1)
      e2 = create(:list_entry, list: list, card_reference: leader_ref, position: 2)

      patch "/api/v1/list_entries/#{e1.id}",
            params: { entry: { position: 2 } }.to_json,
            headers: headers

      expect(e1.reload.position).to eq(2)
      expect(e2.reload.position).to eq(1)
    end
  end

  describe "DELETE /api/v1/list_entries/:id" do
    it "removes the entry and returns the updated list" do
      ref = guild_ref
      entry = create(:list_entry, list: list, card_reference: ref, position: 1)

      delete "/api/v1/list_entries/#{entry.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["entries"]).to be_empty
    end
  end
end
