require 'rails_helper'

RSpec.describe "Api::V1::Abilities", type: :request do
  describe "GET /api/v1/abilities" do
    it "returns all glossary abilities with name, category and description" do
      create(:ability, name: "Acrobatic", category: "character", description: "Re-roll DEXTERITY dice.")
      create(:ability, name: "Poisoned", category: "weapon", description: "Extra Life Point loss.")

      get "/api/v1/abilities"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |a| a["name"] }).to include("Acrobatic", "Poisoned")
      expect(body.first.keys).to match_array(%w[name category description])
    end

    it "filters by category when given" do
      create(:ability, category: "character")
      create(:ability, category: "weapon")

      get "/api/v1/abilities", params: { category: "weapon" }

      body = JSON.parse(response.body)
      expect(body.map { |a| a["category"] }.uniq).to eq(["weapon"])
    end
  end
end
