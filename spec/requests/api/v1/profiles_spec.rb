require 'rails_helper'

RSpec.describe "Api::V1::Profiles", type: :request do
  let!(:profile) do
    create(:profile, faction: "guild", name: "Capodecina", ducats: 30)
  end

  def attach_weapon(name:, damage:)
    weapon = Catalog::Weapon.create!(name: name, damage: damage)
    Catalog::ProfileWeapon.create!(profile: profile, weapon: weapon, position: 1)
    weapon
  end

  describe "GET /api/v1/profiles" do
    it "returns profiles with their embedded weapons, special rules and card references" do
      attach_weapon(name: "Stiletto", damage: 3)
      create(:card_reference, profile: profile, identifier: "guild-capodecina")

      get "/api/v1/profiles"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body).find { |p| p["name"] == "Capodecina" }
      expect(body["weapons"].map { |w| w["name"] }).to include("Stiletto")
      expect(body["card_references"].map { |c| c["identifier"] }).to include("guild-capodecina")
    end

    it "advertises a public, cacheable response and 304s when nothing changed" do
      get "/api/v1/profiles"
      expect(response.headers["Cache-Control"]).to include("public", "max-age")
      etag = response.headers["ETag"]
      expect(etag).to be_present

      get "/api/v1/profiles", headers: { "If-None-Match" => etag }
      expect(response).to have_http_status(:not_modified)
    end

    # S-1: the payload embeds a shared weapon whose own edit touches neither the profile nor the
    # join row. The ETag must still change, or clients keep the stale stats for the cache window.
    it "busts the ETag when an embedded weapon is edited, even though the profile is untouched" do
      weapon = attach_weapon(name: "Stiletto", damage: 3)

      get "/api/v1/profiles"
      etag = response.headers["ETag"]

      weapon.update!(damage: 5) # errata to a shared weapon; no profile row touched

      get "/api/v1/profiles", headers: { "If-None-Match" => etag }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body).find { |p| p["name"] == "Capodecina" }
      expect(body["weapons"].first["damage"]).to eq(5)
    end

    it "busts the ETag when an embedded special rule is edited" do
      rule = Catalog::SpecialRule.create!(name: "Brave", description: "Ignores Fear.")
      Catalog::ProfileSpecialRule.create!(profile: profile, special_rule: rule, position: 1)

      get "/api/v1/profiles"
      etag = response.headers["ETag"]

      rule.update!(description: "Ignores all Fear tests.")

      get "/api/v1/profiles", headers: { "If-None-Match" => etag }
      expect(response).to have_http_status(:ok)
    end

    it "filters by faction" do
      create(:profile, faction: "vatican", name: "Altar Boy")

      get "/api/v1/profiles", params: { faction: "vatican" }

      names = JSON.parse(response.body).map { |p| p["name"] }
      expect(names).to eq(["Altar Boy"])
    end
  end

  describe "GET /api/v1/profiles/:id" do
    it "returns the single profile and 304s when unchanged" do
      get "/api/v1/profiles/#{profile.id}"
      expect(response).to have_http_status(:ok)
      etag = response.headers["ETag"]

      get "/api/v1/profiles/#{profile.id}", headers: { "If-None-Match" => etag }
      expect(response).to have_http_status(:not_modified)
    end
  end
end
