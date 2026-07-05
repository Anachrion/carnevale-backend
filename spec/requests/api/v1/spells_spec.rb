require 'rails_helper'

RSpec.describe "Api::V1::Spells", type: :request do
  describe "GET /api/v1/spells" do
    it "returns all spells with their discipline and cantrip flag" do
      create(:spell, name: "Boiling Veins", discipline: :blood_rites)
      create(:spell, name: "Cantrip of the Devil", discipline: :blood_rites, cantrip: true)

      get "/api/v1/spells"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |s| s["name"] }).to include("Boiling Veins", "Cantrip of the Devil")
      expect(body.first.keys).to include("discipline", "cost", "difficulty", "cantrip", "description")
    end

    it "filters by discipline when given" do
      create(:spell, discipline: :blood_rites)
      create(:spell, discipline: :divinity)

      get "/api/v1/spells", params: { discipline: "divinity" }

      body = JSON.parse(response.body)
      expect(body.map { |s| s["discipline"] }.uniq).to eq(["divinity"])
    end
  end
end
