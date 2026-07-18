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

    it "pins a freshly-hired Leader to the top, shifting the models already hired down" do
      henchman_a = guild_ref(keywords: ["Henchman"])
      henchman_b = guild_ref(keywords: ["Henchman"])
      post_entry(henchman_a)
      post_entry(henchman_b)

      post_entry(guild_ref(keywords: ["Leader"]))

      expect(response).to have_http_status(:created)
      entries = JSON.parse(response.body)["entries"]
      leader = entries.find { |e| e["keywords"].include?("Leader") }
      expect(leader["position"]).to eq(1)
      # The two henchmen that were already hired keep their order, just below the Leader.
      expect(entries.map { |e| e["position"] }.sort).to eq([1, 2, 3])
      expect(entries.reject { |e| e["keywords"].include?("Leader") }.map { |e| e["position"] }).to eq([2, 3])
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
    it "reorders the non-leader models below the pinned Leader" do
      leader = create(:list_entry, list: list, entry: guild_ref(keywords: ["Leader"]), position: 1)
      e2 = create(:list_entry, list: list, entry: guild_ref, position: 2)
      e3 = create(:list_entry, list: list, entry: guild_ref, position: 3)

      # Move the last model up to just below the Leader.
      patch "/api/v1/list_entries/#{e3.id}",
            params: { entry: { position: 2 } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(leader.reload.position).to eq(1)
      expect(e3.reload.position).to eq(2)
      expect(e2.reload.position).to eq(3)
    end

    it "clamps a non-leader that asks for position 1 to just below the Leader" do
      leader = create(:list_entry, list: list, entry: guild_ref(keywords: ["Leader"]), position: 1)
      e2 = create(:list_entry, list: list, entry: guild_ref, position: 2)
      e3 = create(:list_entry, list: list, entry: guild_ref, position: 3)

      patch "/api/v1/list_entries/#{e3.id}",
            params: { entry: { position: 1 } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      # Position 1 stays the Leader's; e3 lands at 2, not above it.
      expect(leader.reload.position).to eq(1)
      expect(e3.reload.position).to eq(2)
      expect(e2.reload.position).to eq(3)
    end

    it "ignores a request to move the Leader" do
      leader = create(:list_entry, list: list, entry: guild_ref(keywords: ["Leader"]), position: 1)
      e2 = create(:list_entry, list: list, entry: guild_ref, position: 2)

      patch "/api/v1/list_entries/#{leader.id}",
            params: { entry: { position: 2 } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(leader.reload.position).to eq(1)
      expect(e2.reload.position).to eq(2)
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

    def pool_id_for(entry)
      entry.profile.profile_spell_pools.first.id
    end

    def patch_spells(entry, discipline:, spell_ids:, pool_id: pool_id_for(entry.entry))
      patch "/api/v1/list_entries/#{entry.id}/spells",
            params: { entry: { pool_selections: [ { pool_id: pool_id, disciplines: [ discipline ], spell_ids: spell_ids } ] } }.to_json,
            headers: headers
    end

    it "sets the discipline and known spells, exposing them on the entry's pool" do
      cantrip = create(:spell, discipline: :blood_rites, cantrip: true)
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
      spells = create_list(:spell, 2, discipline: :blood_rites)

      patch_spells(entry, discipline: "blood_rites", spell_ids: spells.map(&:id))

      expect(response).to have_http_status(:ok)
      returned = JSON.parse(response.body)["entries"].first
      pool = returned["pools"].first
      expect(pool["chosen_disciplines"]).to eq([ "blood_rites" ])
      expect(pool["spells"].map { |s| s["id"] }).to match_array(spells.map(&:id))
      expect(returned["mage"]).to be true
      expect(pool["slot_count"]).to eq(3)
      expect(pool["cantrips"].map { |s| s["id"] }).to eq([ cantrip.id ])
    end

    it "replaces a previous selection rather than appending" do
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
      first = create(:spell, discipline: :blood_rites)
      second = create(:spell, discipline: :divinity)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [first.id])
      patch_spells(entry, discipline: "divinity", spell_ids: [second.id])

      returned = JSON.parse(response.body)["entries"].first
      expect(returned["pools"].first["spells"].map { |s| s["id"] }).to eq([second.id])
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
      ref = mage_ref
      entry = create(:list_entry, list: other, entry: ref, position: 1)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [], pool_id: pool_id_for(ref))
      expect(response).to have_http_status(:not_found)
    end

    # B-17: a spell_id that doesn't exist makes entry_spells.create! raise RecordInvalid (spell is a
    # required belongs_to). It used to escape as a 500; the base controller now renders it as a 422
    # in the API's `{ errors: {...} }` shape.
    it "returns a 422 in the API error shape for an unknown spell id" do
      entry = create(:list_entry, list: list, entry: mage_ref, position: 1)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [999_999])

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "rejects the edit once the game's owning player has confirmed their Agendas" do
      game_player = create(:game_player, user: user, agendas_confirmed: true)
      snapshot_list = create(:list, owner: game_player, faction: :guild, points: 100)
      entry = create(:list_entry, list: snapshot_list, entry: mage_ref, position: 1)

      patch_spells(entry, discipline: "blood_rites", spell_ids: [])

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]["base"].join).to match(/locked in for this game/)
    end

    describe "Apprentice Doctor's mentor pick" do
      def mentor_derived_ref
        profile = create(:profile, faction: :guild, ducats: 15)
        profile.replace_spell_pools!([ { of: 1, slot_count: 0, mentor_derived: true, grants_cantrip: true, disciplines: [] } ])
        create(:card_reference, profile: profile)
      end

      it "sets the mentor and resolves the pool's disciplines/slot_count from it" do
        mentor_entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
        apprentice_entry = create(:list_entry, list: list, entry: mentor_derived_ref, position: 2)

        patch "/api/v1/list_entries/#{apprentice_entry.id}/spells",
              params: { entry: { mentored_by_entry_id: mentor_entry.id, pool_selections: [] } }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)
        returned = JSON.parse(response.body)["entries"].find { |e| e["id"] == apprentice_entry.id }
        expect(returned["mentored_by_entry_id"]).to eq(mentor_entry.id)
        expect(returned["pools"].first["eligible_disciplines"]).to eq([ "blood_rites", "divinity" ])
        # mage_ref is Mage (2) + Expert Sorcerer (1) = 3 total, but Apprenticeship only ever copies
        # the Mage ability — mage_slot_count (2), not the mentor's combined slot_count (3).
        expect(returned["pools"].first["slot_count"]).to eq(2)
      end

      it "leaves the current mentor untouched when the field is omitted" do
        mentor_entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
        apprentice_entry = create(:list_entry, list: list, entry: mentor_derived_ref, position: 2,
                                   mentored_by_entry: mentor_entry)
        pool_id = apprentice_entry.profile.profile_spell_pools.first.id

        patch "/api/v1/list_entries/#{apprentice_entry.id}/spells",
              params: { entry: { pool_selections: [ { pool_id: pool_id, disciplines: [], spell_ids: [] } ] } }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)
        expect(apprentice_entry.reload.mentored_by_entry_id).to eq(mentor_entry.id)
      end

      it "clears the mentor when the field is sent as null" do
        mentor_entry = create(:list_entry, list: list, entry: mage_ref, position: 1)
        apprentice_entry = create(:list_entry, list: list, entry: mentor_derived_ref, position: 2,
                                   mentored_by_entry: mentor_entry)

        patch "/api/v1/list_entries/#{apprentice_entry.id}/spells",
              params: { entry: { mentored_by_entry_id: nil, pool_selections: [] } }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)
        expect(apprentice_entry.reload.mentored_by_entry_id).to be_nil
      end

      it "rejects a mentor entry from another user's list" do
        other_list = create(:list, faction: :guild, points: 100)
        other_mentor_entry = create(:list_entry, list: other_list, entry: mage_ref, position: 1)
        apprentice_entry = create(:list_entry, list: list, entry: mentor_derived_ref, position: 2)

        patch "/api/v1/list_entries/#{apprentice_entry.id}/spells",
              params: { entry: { mentored_by_entry_id: other_mentor_entry.id, pool_selections: [] } }.to_json,
              headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /api/v1/list_entries/:id/illustration" do
    # Two card references for one profile — the "different illustration, same model" case.
    def two_refs
      profile = create(:profile, faction: :guild, ducats: 10, keywords: ["Leader"])
      [create(:card_reference, profile: profile, illustration_number: 1),
       create(:card_reference, profile: profile, illustration_number: 2)]
    end

    def patch_illustration(entry, entry_id:)
      patch "/api/v1/list_entries/#{entry.id}/illustration",
            params: { entry: { entry_id: entry_id } }.to_json,
            headers: headers
    end

    it "repoints the entry at a sibling card reference of the same profile" do
      ref_a, ref_b = two_refs
      entry = create(:list_entry, list: list, entry: ref_a, position: 1)

      patch_illustration(entry, entry_id: ref_b.id)

      expect(response).to have_http_status(:ok)
      returned = JSON.parse(response.body)["entries"].first
      expect(returned["entry_id"]).to eq(ref_b.id)
      expect(returned["identifier"]).to eq(ref_b.identifier)
      expect(returned["card_front"]).to eq(ref_b.card_front)
      # Same profile, so the model name is unchanged by the illustration switch.
      expect(returned["profile_name"]).to eq(ref_b.profile.name)
      expect(entry.reload.entry_id).to eq(ref_b.id)
    end

    it "rejects a reference belonging to a different profile" do
      ref_a, = two_refs
      other = create(:card_reference, profile: create(:profile, faction: :guild, ducats: 10))
      entry = create(:list_entry, list: list, entry: ref_a, position: 1)

      patch_illustration(entry, entry_id: other.id)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(entry.reload.entry_id).to eq(ref_a.id)
    end

    it "returns 404 when the entry belongs to another user" do
      ref_a, ref_b = two_refs
      other = create(:list, faction: :guild, points: 100)
      entry = create(:list_entry, list: other, entry: ref_a, position: 1)

      patch_illustration(entry, entry_id: ref_b.id)
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
