require 'rails_helper'

RSpec.describe "Api::V1::Games", type: :request do
  # Two players means two independent HTTP clients — plain `post`/`get` here share one cookie
  # jar (Devise's session-based "already signed in" guard then blocks logging in as the second
  # user), so each simulated player gets its own `open_session`.
  let(:host_user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:guest_user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  def headers_for(session, user)
    session.post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }.to_json, headers: json_headers
    json_headers.merge("Authorization" => session.response.headers["Authorization"])
  end

  def json(session)
    JSON.parse(session.response.body)
  end

  let!(:scenario) { create(:scenario, name: "Gang War", ducats: 150, asymmetric: false) }
  let!(:agendas) { %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) } }

  describe "POST /api/v1/games" do
    it "creates a game hosted by the current user, defaulting ducat_limit from the scenario" do
      host = open_session
      h = headers_for(host, host_user)
      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h

      expect(host.response).to have_http_status(:created)
      expect(json(host)["ducat_limit"]).to eq(150)
      expect(json(host)["status"]).to eq("pending")
      expect(json(host)["join_code"]).to match(/\A[A-Z0-9]{6}\z/)
      expect(json(host)["players"].size).to eq(1)
      expect(json(host)["players"].first).to include("username" => host_user.username, "host" => true)
    end

    it "allows overriding the ducat limit" do
      host = open_session
      h = headers_for(host, host_user)
      host.post "/api/v1/games", params: { scenario_id: scenario.id, ducat_limit: 80 }.to_json, headers: h
      expect(json(host)["ducat_limit"]).to eq(80)
    end
  end

  describe "the full 2-player happy path" do
    it "walks a symmetric scenario from creation through in_progress" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      join_code = json(host)["join_code"]

      guest.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: g
      expect(guest.response).to have_http_status(:ok)
      expect(json(guest)["status"]).to eq("gang_selection")
      expect(json(guest)["players"].size).to eq(2)

      host_list = create(:list, user: host_user, faction: "guild", points: 100)
      guest_list = create(:list, user: guest_user, faction: "doctors", points: 100)

      host.get "/api/v1/games/#{game_id}/available_lists", headers: h
      expect(json(host).first).to include("selectable" => true)

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["status"]).to eq("gang_selection")

      guest.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: guest_list.id }.to_json, headers: g
      expect(json(guest)["status"]).to eq("agenda_draw")

      host.post "/api/v1/games/#{game_id}/agendas/draw", headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["agendas"].size).to eq(3)

      guest.post "/api/v1/games/#{game_id}/agendas/draw", headers: g
      host.get "/api/v1/games/#{game_id}", headers: h
      expect(json(host)["status"]).to eq("deployment_rolloff")

      host.post "/api/v1/games/#{game_id}/deployment_roll", headers: h
      guest.post "/api/v1/games/#{game_id}/deployment_roll", headers: g
      host.get "/api/v1/games/#{game_id}", headers: h
      winner_id = json(host)["deployment_roll_winner_id"]
      expect(winner_id).to be_present

      winner_user = GamePlayer.find(winner_id).user
      winner_session = winner_user == host_user ? host : guest
      winner_headers = winner_user == host_user ? h : g
      winner_session.patch "/api/v1/games/#{game_id}/deployment_zone", params: { zone: "A" }.to_json, headers: winner_headers
      expect(winner_session.response).to have_http_status(:ok)
      expect(json(winner_session)["status"]).to eq("deploying")
      expect(json(winner_session)["players"].map { |p| p["deployment_zone"] }.sort).to eq(%w[A B])

      host.post "/api/v1/games/#{game_id}/ready", headers: h
      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(json(guest)["status"]).to eq("deploying")

      guest.post "/api/v1/games/#{game_id}/ready", headers: g
      expect(json(guest)["status"]).to eq("in_progress")
    end
  end

  describe "asymmetric scenarios" do
    let!(:street_fight) { create(:scenario, name: "Street Fight", ducats: 100, asymmetric: true) }

    it "blocks gang selection until the role roll-off is resolved, then gates on it" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: street_fight.id }.to_json, headers: h
      game_id = json(host)["id"]
      join_code = json(host)["join_code"]
      guest.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: g

      host.get "/api/v1/games/#{game_id}/available_lists", headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)

      host.post "/api/v1/games/#{game_id}/role_roll", headers: h
      guest.post "/api/v1/games/#{game_id}/role_roll", headers: g
      host.get "/api/v1/games/#{game_id}", headers: h
      winner_id = json(host)["role_roll_winner_id"]
      expect(winner_id).to be_present

      winner_user = GamePlayer.find(winner_id).user
      winner_session = winner_user == host_user ? host : guest
      winner_headers = winner_user == host_user ? h : g
      winner_session.patch "/api/v1/games/#{game_id}/role", params: { role: "attacker" }.to_json, headers: winner_headers
      expect(winner_session.response).to have_http_status(:ok)
      expect(json(winner_session)["players"].map { |p| p["role"] }.sort).to eq(%w[attacker defender])

      host.get "/api/v1/games/#{game_id}/available_lists", headers: h
      expect(host.response).to have_http_status(:ok)
    end
  end

  describe "guard rails" do
    it "rejects selecting a gang that exceeds the ducat limit" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id, ducat_limit: 50 }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      too_big = create(:list, user: host_user, points: 100)
      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: too_big.id }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for a game the user is not a participant of" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      guest.get "/api/v1/games/#{json(host)["id"]}", headers: g
      expect(guest.response).to have_http_status(:not_found)
    end

    it "rejects joining a full game" do
      host = open_session
      guest = open_session
      other = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      join_code = json(host)["join_code"]
      guest.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: g

      third_user = create(:user, password: "password123", password_confirmation: "password123")
      o = headers_for(other, third_user)
      other.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: o
      expect(other.response).to have_http_status(:unprocessable_entity)
    end

    it "returns 401 when not authenticated" do
      get "/api/v1/games", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
