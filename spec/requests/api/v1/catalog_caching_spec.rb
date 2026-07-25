require 'rails_helper'

# Covers the HTTP caching added to the (immutable, seed-managed) catalogue endpoints so proxies
# such as Thruster can cache them and unchanged data returns a cheap 304.
RSpec.describe "Api::V1 catalogue caching", type: :request do
  describe "GET /api/v1/spells" do
    before { create(:spell) }

    it "advertises a privately cacheable response with a validator" do
      get "/api/v1/spells"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Cache-Control"]).to include("private", "max-age")
      # Never "public": Thruster would then shared-cache this by URL alone and serve it
      # without the X-Api-Key check ever running. See AuthenticatesClient.
      expect(response.headers["Cache-Control"]).not_to include("public")
      expect(response.headers["ETag"]).to be_present
    end

    it "returns 304 Not Modified when the client's ETag still matches" do
      get "/api/v1/spells"
      etag = response.headers["ETag"]

      get "/api/v1/spells", headers: { "If-None-Match" => etag }

      expect(response).to have_http_status(:not_modified)
      expect(response.body).to be_empty
    end

    it "serves a fresh response once the catalogue changes" do
      get "/api/v1/spells"
      etag = response.headers["ETag"]

      create(:spell)
      get "/api/v1/spells", headers: { "If-None-Match" => etag }

      expect(response).to have_http_status(:ok)
    end
  end
end
