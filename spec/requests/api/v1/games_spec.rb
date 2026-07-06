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

  # Runs the whole setup flow (not factories straight to in_progress) so the entries the entry-state
  # endpoints poke at are the snapshotted ones they actually resolve, with real entry states. The
  # host's model is given non-zero HP/WP/CP so stat edits have something to move.
  def start_game_with_models(ready: true)
    host = open_session
    guest = open_session
    h = headers_for(host, host_user)
    g = headers_for(guest, guest_user)

    host_list = create(:list, owner: host_user, faction: "guild", points: 100)
    create(:list_entry, list: host_list,
           entry: create(:reference, profile: create(:profile, life_points: 10, will_points: 3, command_points: 1)))
    guest_list = create(:list, owner: guest_user, faction: "doctors", points: 100)
    create(:list_entry, list: guest_list)

    host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
    game_id = json(host)["id"]
    guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

    host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
    guest.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: guest_list.id }.to_json, headers: g
    host.post "/api/v1/games/#{game_id}/agendas/draw", headers: h
    guest.post "/api/v1/games/#{game_id}/agendas/draw", headers: g
    if ready
      host.post "/api/v1/games/#{game_id}/ready", headers: h
      guest.post "/api/v1/games/#{game_id}/ready", headers: g
    end

    guest.get "/api/v1/games/#{game_id}", headers: g
    players = json(guest)["players"]
    host_player_id = players.find { |p| p["username"] == host_user.username }["id"]
    guest_player_id = players.find { |p| p["username"] == guest_user.username }["id"]
    host.get "/api/v1/games/#{game_id}/players/#{host_player_id}/list", headers: h
    host_entry_id = json(host)["entries"].first["id"]
    host.get "/api/v1/games/#{game_id}/players/#{guest_player_id}/list", headers: h
    guest_entry_id = json(host)["entries"].first["id"]

    [ host, guest, h, g, game_id, host_entry_id, guest_entry_id ]
  end

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

    it "defaults the name to the scenario's name when not provided" do
      host = open_session
      h = headers_for(host, host_user)
      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      expect(json(host)["name"]).to eq("Gang War")
    end

    it "allows overriding the name" do
      host = open_session
      h = headers_for(host, host_user)
      host.post "/api/v1/games", params: { scenario_id: scenario.id, name: "Rivals in the Rain" }.to_json, headers: h
      expect(json(host)["name"]).to eq("Rivals in the Rain")
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

      host_list = create(:list, owner: host_user, faction: "guild", points: 100)
      guest_list = create(:list, owner: guest_user, faction: "doctors", points: 100)

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
      expect(json(host)["status"]).to eq("deploying")

      winner_id = json(host)["players"].find { |p| p["won_deployment_roll"] }&.fetch("id")
      expect(winner_id).to be_present

      host.post "/api/v1/games/#{game_id}/ready", headers: h
      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(json(guest)["status"]).to eq("deploying")

      guest.post "/api/v1/games/#{game_id}/ready", headers: g
      expect(json(guest)["status"]).to eq("in_progress")
    end
  end

  describe "agenda scoring and turn tracking" do
    def start_in_progress_game(turns: 5, agenda_rules: [])
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      short_scenario = create(:scenario, name: "Short Scenario", ducats: 100, turns: turns, agenda_rules: agenda_rules)
      host.post "/api/v1/games", params: { scenario_id: short_scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host_list = create(:list, owner: host_user, faction: "guild", points: 100)
      guest_list = create(:list, owner: guest_user, faction: "doctors", points: 100)
      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      guest.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: guest_list.id }.to_json, headers: g

      host.post "/api/v1/games/#{game_id}/agendas/draw", headers: h
      guest.post "/api/v1/games/#{game_id}/agendas/draw", headers: g
      host.post "/api/v1/games/#{game_id}/ready", headers: h
      guest.post "/api/v1/games/#{game_id}/ready", headers: g

      [ host, guest, h, g, game_id ]
    end

    it "draws, scores (auto-recycling under Cycle), discards, and advances turns through to completion" do
      host, _guest, h, _g, game_id = start_in_progress_game(turns: 2, agenda_rules: [ "cycle" ])

      expect(json(host)["current_turn"]).to eq(1)

      host.post "/api/v1/games/#{game_id}/agendas/draw", params: { origin: "special_rule" }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["agendas"].size).to eq(4)

      host.get "/api/v1/games/#{game_id}", headers: h
      host_entry = json(host)["players"].find { |p| p["username"] == host_user.username }
      scored_agenda_id = host_entry["agendas"].first["id"]

      # No recycle flag in the body — the scenario's Cycle rule drives the replacement draw.
      host.post "/api/v1/games/#{game_id}/agendas/#{scored_agenda_id}/score", headers: h
      expect(host.response).to have_http_status(:ok)
      host_entry = json(host)["players"].find { |p| p["username"] == host_user.username }
      expect(host_entry["score"]).to eq(1)
      expect(host_entry["agendas"].size).to eq(4)
      expect(host_entry["agenda_history"].map { |e| e["action"] }).to include("scored")
      expect(host_entry["agenda_history"].find { |e| e["origin"] == "recycle" }).to be_present

      discard_agenda_id = host_entry["agendas"].first["id"]
      host.post "/api/v1/games/#{game_id}/agendas/#{discard_agenda_id}/discard", params: { origin: "command_point" }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)

      host.post "/api/v1/games/#{game_id}/turns/advance", headers: h
      expect(json(host)["current_turn"]).to eq(2)

      host.post "/api/v1/games/#{game_id}/turns/advance", headers: h
      expect(json(host)["status"]).to eq("completed")
    end

    it "does not auto-recycle when scoring under a scenario without the Cycle rule" do
      host, _guest, h, _g, game_id = start_in_progress_game

      host.get "/api/v1/games/#{game_id}", headers: h
      host_entry = json(host)["players"].find { |p| p["username"] == host_user.username }
      agenda_id = host_entry["agendas"].first["id"]

      host.post "/api/v1/games/#{game_id}/agendas/#{agenda_id}/score", headers: h
      host_entry = json(host)["players"].find { |p| p["username"] == host_user.username }
      expect(host_entry["agendas"].size).to eq(2)
      expect(host_entry["agenda_history"].any? { |e| e["origin"] == "recycle" }).to be false
    end

    it "rejects scoring an agenda not in the player's hand" do
      host, _guest, h, _g, game_id = start_in_progress_game
      other_agenda = create(:agenda)

      host.post "/api/v1/games/#{game_id}/agendas/#{other_agenda.id}/score", headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "requires a valid origin when discarding" do
      host, _guest, h, _g, game_id = start_in_progress_game
      host.get "/api/v1/games/#{game_id}", headers: h
      agenda_id = json(host)["players"].find { |p| p["username"] == host_user.username }["agendas"].first["id"]

      host.post "/api/v1/games/#{game_id}/agendas/#{agenda_id}/discard", headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "requires a valid origin when drawing mid-game" do
      host, _guest, h, _g, game_id = start_in_progress_game

      host.post "/api/v1/games/#{game_id}/agendas/draw", params: { origin: "bogus" }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "rejects advancing the turn outside in_progress" do
      host = open_session
      h = headers_for(host, host_user)
      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]

      host.post "/api/v1/games/#{game_id}/turns/advance", headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "agenda visibility and the pre-game mulligan" do
    # create → join → gang select → initial draw, leaving the game in the setup window (status
    # `deploying`, since both players have drawn). Returns the sessions, headers, game id, and ids.
    def setup_through_draw(agenda_rules: [])
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      vis_scenario = create(:scenario, name: "Vis Scenario #{agenda_rules.join('-')}", ducats: 100, agenda_rules: agenda_rules)
      host.post "/api/v1/games", params: { scenario_id: vis_scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host_list = create(:list, owner: host_user, faction: "guild", points: 100)
      guest_list = create(:list, owner: guest_user, faction: "doctors", points: 100)
      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      guest.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: guest_list.id }.to_json, headers: g
      host.post "/api/v1/games/#{game_id}/agendas/draw", headers: h
      guest.post "/api/v1/games/#{game_id}/agendas/draw", headers: g

      guest.get "/api/v1/games/#{game_id}", headers: g
      players = json(guest)["players"]
      host_pid = players.find { |p| p["username"] == host_user.username }["id"]
      guest_pid = players.find { |p| p["username"] == guest_user.username }["id"]
      [ host, guest, h, g, game_id, host_pid, guest_pid ]
    end

    def go_live(host, guest, h, g, game_id)
      host.post "/api/v1/games/#{game_id}/ready", headers: h
      guest.post "/api/v1/games/#{game_id}/ready", headers: g
    end

    it "shows each opponent's hand to the other when the scenario is not Secret" do
      host, guest, h, g, game_id, host_pid, _ = setup_through_draw
      go_live(host, guest, h, g, game_id)

      guest.get "/api/v1/games/#{game_id}", headers: g
      host_entry = json(guest)["players"].find { |p| p["id"] == host_pid }
      expect(host_entry["agendas"].size).to eq(3)
    end

    it "hides an opponent's in-hand agendas under the Secret rule, but not from the owner" do
      host, guest, h, g, game_id, host_pid, _ = setup_through_draw(agenda_rules: [ "secret" ])
      go_live(host, guest, h, g, game_id)

      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(json(guest)["players"].find { |p| p["id"] == host_pid }["agendas"]).to be_empty

      host.get "/api/v1/games/#{game_id}", headers: h
      expect(json(host)["players"].find { |p| p["id"] == host_pid }["agendas"].size).to eq(3)
    end

    it "reveals a Secret opponent's scored and discarded agendas but not their remaining hand" do
      host, guest, h, g, game_id, host_pid, _ = setup_through_draw(agenda_rules: [ "secret" ])
      go_live(host, guest, h, g, game_id)

      host.get "/api/v1/games/#{game_id}", headers: h
      hand = json(host)["players"].find { |p| p["id"] == host_pid }["agendas"]
      host.post "/api/v1/games/#{game_id}/agendas/#{hand[0]['id']}/score", headers: h
      host.post "/api/v1/games/#{game_id}/agendas/#{hand[1]['id']}/discard", params: { origin: "command_point" }.to_json, headers: h

      guest.get "/api/v1/games/#{game_id}", headers: g
      host_entry = json(guest)["players"].find { |p| p["id"] == host_pid }
      expect(host_entry["agendas"]).to be_empty
      actions = host_entry["agenda_history"].map { |e| e["action"] }
      expect(actions).to include("scored", "discarded")
      expect(actions).not_to include("drawn")
    end

    it "lets a player mulligan an unachievable agenda during setup and redraws a replacement" do
      host, _guest, h, _g, game_id, host_pid, _ = setup_through_draw
      host.get "/api/v1/games/#{game_id}", headers: h
      discard_id = json(host)["players"].find { |p| p["id"] == host_pid }["agendas"].first["id"]

      host.post "/api/v1/games/#{game_id}/agendas/#{discard_id}/discard", params: { origin: "unachievable" }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)

      host_entry = json(host)["players"].find { |p| p["id"] == host_pid }
      expect(host_entry["agendas"].size).to eq(3)
      expect(host_entry["agendas"].map { |a| a["id"] }).not_to include(discard_id)
      expect(host_entry["agenda_history"].any? { |e| e["origin"] == "unachievable" }).to be true
      expect(host_entry["agenda_history"].any? { |e| e["origin"] == "recycle" }).to be true
    end

    it "rejects the unachievable mulligan once the game is in progress" do
      host, guest, h, g, game_id, host_pid, _ = setup_through_draw
      go_live(host, guest, h, g, game_id)

      host.get "/api/v1/games/#{game_id}", headers: h
      agenda_id = json(host)["players"].find { |p| p["id"] == host_pid }["agendas"].first["id"]
      host.post "/api/v1/games/#{game_id}/agendas/#{agenda_id}/discard", params: { origin: "unachievable" }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/games/:id/players/:player_id/list" do
    it "lets either participant view either player's selected gang once picked" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host_list = create(:list, owner: host_user, faction: "guild", points: 100, name: "Host's Gang")
      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      host_player_id = json(host)["players"].find { |p| p["username"] == host_user.username }["id"]

      guest.get "/api/v1/games/#{game_id}/players/#{host_player_id}/list", headers: g
      expect(guest.response).to have_http_status(:ok)
      expect(json(guest)["name"]).to eq("Host's Gang")

      guest_player_id = json(host)["players"].find { |p| p["username"] == guest_user.username }["id"]
      guest.get "/api/v1/games/#{game_id}/players/#{guest_player_id}/list", headers: g
      expect(guest.response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for a game the user isn't a participant of" do
      host = open_session
      other = open_session
      h = headers_for(host, host_user)
      other_user = create(:user, password: "password123", password_confirmation: "password123")
      o = headers_for(other, other_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      host_player_id = json(host)["players"].first["id"]

      other.get "/api/v1/games/#{game_id}/players/#{host_player_id}/list", headers: o
      expect(other.response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/games/:id/entries/:list_entry_id/counters" do
    it "toggles counters on the player's own model, merging partial updates" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { stunned: true } }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)).to include("stunned" => true, "hidden" => false, "underwater_counters" => 0)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { underwater_counters: 2, hidden: true } }.to_json, headers: h
      expect(json(host)).to include("stunned" => true, "hidden" => true, "underwater_counters" => 2)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { stunned: false } }.to_json, headers: h
      expect(json(host)).to include("stunned" => false, "hidden" => true, "underwater_counters" => 2)
    end

    it "returns 404 for the opponent's models" do
      _host, guest, _h, g, game_id, host_entry_id, = start_game_with_models

      guest.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                  params: { counters: { stunned: true } }.to_json, headers: g
      expect(guest.response).to have_http_status(:not_found)
    end

    it "rejects invalid counter values" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { underwater_counters: 3 } }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { stunned: "yes" } }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "rejects updates while the game isn't in progress" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models(ready: false)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/counters",
                 params: { counters: { stunned: true } }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/games/:id/entries/:list_entry_id/stats" do
    it "sets current HP/WP/CP on the player's own model, merging partial updates" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/stats",
                 params: { stats: { life_points: 7 } }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["life_points"]).to eq("current" => 7, "starting" => 10)
      # Untouched stats keep their snapshotted values.
      expect(json(host)["will_points"]).to eq("current" => 3, "starting" => 3)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/stats",
                 params: { stats: { will_points: 1, command_points: 0 } }.to_json, headers: h
      expect(json(host)["life_points"]["current"]).to eq(7)
      expect(json(host)["will_points"]["current"]).to eq(1)
      expect(json(host)["command_points"]["current"]).to eq(0)
    end

    it "returns 404 for the opponent's models" do
      _host, guest, _h, g, game_id, host_entry_id, = start_game_with_models

      guest.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/stats",
                  params: { stats: { life_points: 5 } }.to_json, headers: g
      expect(guest.response).to have_http_status(:not_found)
    end

    it "rejects a negative stat value" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/stats",
                 params: { stats: { life_points: -1 } }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
    end

    it "rejects updates while the game isn't in progress" do
      host, _guest, h, _g, game_id, host_entry_id, = start_game_with_models(ready: false)

      host.patch "/api/v1/games/#{game_id}/entries/#{host_entry_id}/stats",
                 params: { stats: { life_points: 5 } }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
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

      host.get "/api/v1/games/#{game_id}", headers: h
      winner_id = json(host)["players"].find { |p| p["won_role_roll"] }&.fetch("id")
      expect(winner_id).to be_present

      winner_user = Encounter::Player.find(winner_id).user
      winner_session = winner_user == host_user ? host : guest
      winner_headers = winner_user == host_user ? h : g
      winner_session.patch "/api/v1/games/#{game_id}/role", params: { role: "attacker" }.to_json, headers: winner_headers
      expect(winner_session.response).to have_http_status(:ok)
      expect(json(winner_session)["players"].map { |p| p["role"] }.sort).to eq(%w[attacker defender])

      host.get "/api/v1/games/#{game_id}/available_lists", headers: h
      expect(host.response).to have_http_status(:ok)
    end
  end

  describe "list snapshotting" do
    it "freezes the selected list, so later edits to the live list don't change the game" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)
      host_list = create(:list, owner: host_user, faction: "guild", points: 100, name: "Original Name")

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      expect(json(host)["players"].find { |p| p["username"] == host_user.username }["list"]["name"]).to eq("Original Name")

      host_list.update!(name: "Renamed after the match")

      host.get "/api/v1/games/#{game_id}", headers: h
      expect(json(host)["players"].find { |p| p["username"] == host_user.username }["list"]["name"]).to eq("Original Name")
    end

    it "destroys the frozen snapshot once the game is hard-deleted, leaving the live list untouched" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)
      host_list = create(:list, owner: host_user, faction: "guild", points: 100)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g
      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      snapshot_id = json(host)["players"].find { |p| p["username"] == host_user.username }["list"]["id"]

      host.delete "/api/v1/games/#{game_id}", headers: h
      guest.delete "/api/v1/games/#{game_id}", headers: g

      expect(Gang::List.exists?(snapshot_id)).to be false
      expect(Gang::List.exists?(host_list.id)).to be true
    end
  end

  describe "archiving and deleting" do
    it "archives a game for one user only, hiding it from their list but keeping it reachable" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host.patch "/api/v1/games/#{game_id}/archive", headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["viewer_visibility"]).to eq("archived")

      host.get "/api/v1/games", headers: h
      expect(json(host)).to be_empty

      host.get "/api/v1/games?visibility=archived", headers: h
      expect(json(host).map { |g| g["id"] }).to eq([ game_id ])

      host.get "/api/v1/games/#{game_id}", headers: h
      expect(host.response).to have_http_status(:ok)

      guest.get "/api/v1/games", headers: g
      expect(json(guest).size).to eq(1)

      guest.get "/api/v1/games?visibility=archived", headers: g
      expect(json(guest)).to be_empty
    end

    it "soft-deletes a game for one user only, making it inaccessible to them but not the opponent" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host.delete "/api/v1/games/#{game_id}", headers: h
      expect(host.response).to have_http_status(:no_content)

      host.get "/api/v1/games/#{game_id}", headers: h
      expect(host.response).to have_http_status(:not_found)

      host.get "/api/v1/games", headers: h
      expect(json(host)).to be_empty

      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(guest.response).to have_http_status(:ok)
      expect(Encounter::Game.exists?(game_id)).to be true
    end

    it "hard-deletes the game once every player has deleted it" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host.delete "/api/v1/games/#{game_id}", headers: h
      guest.delete "/api/v1/games/#{game_id}", headers: g
      expect(guest.response).to have_http_status(:no_content)

      expect(Encounter::Game.exists?(game_id)).to be false
    end

    it "returns 204 (not 500) when the game is already gone as the last delete lands (concurrent race)" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      # Stand in for the other player's concurrent delete winning the race and tearing the game down
      # between this request loading it and taking the row lock.
      allow_any_instance_of(Encounter::Game).to receive(:with_lock).and_raise(ActiveRecord::RecordNotFound)

      host.delete "/api/v1/games/#{game_id}", headers: h
      expect(host.response).to have_http_status(:no_content)
    end

    it "unarchives a game for one user only, restoring it to their list" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g

      host.patch "/api/v1/games/#{game_id}/archive", headers: h
      host.get "/api/v1/games", headers: h
      expect(json(host)).to be_empty

      host.patch "/api/v1/games/#{game_id}/unarchive", headers: h
      expect(host.response).to have_http_status(:ok)
      expect(json(host)["viewer_visibility"]).to eq("active")

      host.get "/api/v1/games", headers: h
      expect(json(host).size).to eq(1)
    end

    it "restores the game for a user who deleted it and then rejoins via the join code" do
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      join_code = json(host)["join_code"]
      guest.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: g

      guest.delete "/api/v1/games/#{game_id}", headers: g
      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(guest.response).to have_http_status(:not_found)

      guest.post "/api/v1/games/join", params: { join_code: join_code }.to_json, headers: g
      expect(guest.response).to have_http_status(:ok)
      expect(json(guest)["viewer_visibility"]).to eq("active")

      guest.get "/api/v1/games/#{game_id}", headers: g
      expect(guest.response).to have_http_status(:ok)
    end
  end

  # Non-regression for B-P1-2: re-selecting a gang used to reassign a NOT-NULL-owned has_one,
  # which either 500'd or orphaned the previous snapshot, and there was no status guard at all.
  describe "re-selecting a gang" do
    def start_selection
      host = open_session
      guest = open_session
      h = headers_for(host, host_user)
      g = headers_for(guest, guest_user)

      host.post "/api/v1/games", params: { scenario_id: scenario.id }.to_json, headers: h
      game_id = json(host)["id"]
      guest.post "/api/v1/games/join", params: { join_code: json(host)["join_code"] }.to_json, headers: g
      [ host, guest, h, g, game_id ]
    end

    it "cleanly replaces the previous snapshot without a 500 or an orphaned list" do
      host, _guest, h, _g, game_id = start_selection
      first_list = create(:list, owner: host_user, faction: "guild", points: 100, name: "First Choice")
      second_list = create(:list, owner: host_user, faction: "doctors", points: 100, name: "Second Choice")

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: first_list.id }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)
      first_snapshot_id = json(host)["players"].find { |p| p["username"] == host_user.username }["list"]["id"]

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: second_list.id }.to_json, headers: h
      expect(host.response).to have_http_status(:ok)

      current = json(host)["players"].find { |p| p["username"] == host_user.username }["list"]
      expect(current["name"]).to eq("Second Choice")
      # The old snapshot is gone (not orphaned), and the game-player owns exactly one snapshot.
      expect(Gang::List.exists?(first_snapshot_id)).to be false
      player = Encounter::Game.find(game_id).game_players.find_by(user: host_user)
      expect(Gang::List.where(owner: player).count).to eq(1)
    end

    it "rejects changing a gang once selection is complete and the game has advanced" do
      host, guest, h, g, game_id = start_selection
      host_list = create(:list, owner: host_user, faction: "guild", points: 100)
      guest_list = create(:list, owner: guest_user, faction: "doctors", points: 100)
      other_list = create(:list, owner: host_user, faction: "doctors", points: 100)

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: host_list.id }.to_json, headers: h
      guest.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: guest_list.id }.to_json, headers: g
      expect(json(guest)["status"]).to eq("agenda_draw")

      host.patch "/api/v1/games/#{game_id}/select_gang", params: { list_id: other_list.id }.to_json, headers: h
      expect(host.response).to have_http_status(:unprocessable_entity)
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

      too_big = create(:list, owner: host_user, points: 100)
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
