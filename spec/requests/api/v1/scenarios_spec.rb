require 'rails_helper'

RSpec.describe "Api::V1::Scenarios", type: :request do
  describe "GET /api/v1/scenarios" do
    it "returns all scenarios, no auth required" do
      create(:scenario, name: "Gang War", ducats: 150)
      create(:scenario, name: "Street Fight", ducats: 100, asymmetric: true)

      get "/api/v1/scenarios", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |s| s["name"] }).to contain_exactly("Gang War", "Street Fight")
      expect(body.find { |s| s["name"] == "Street Fight" }).to include("asymmetric" => true, "ducats" => 100)
    end
  end
end
