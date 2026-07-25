require 'rails_helper'

RSpec.describe "Api::V1::RulesDocuments", type: :request do
  describe "GET /api/v1/rules_documents" do
    it "returns the configured documents in order, no auth required" do
      get "/api/v1/rules_documents", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |d| d["title"] }).to eq(
        [
          "Carnevale Rulebook",
          "2.3 Carnevale FAQ",
          "Magic Disciplines",
          "Agendas",
          "Abilities Sheet",
          "Quick Reference Sheet"
        ]
      )
      expect(body.first["key"]).to eq("rulebook")
      expect(body.first["url"]).to start_with("https://")
    end

    it "advertises a privately cacheable response with a validator" do
      get "/api/v1/rules_documents"

      expect(response).to have_http_status(:ok)
      expect(response.headers["Cache-Control"]).to include("private", "max-age")
      # Never "public": Thruster would then shared-cache this by URL alone and serve it
      # without the X-Api-Key check ever running. See AuthenticatesClient.
      expect(response.headers["Cache-Control"]).not_to include("public")
      expect(response.headers["ETag"]).to be_present
    end

    it "returns 304 Not Modified when the client's ETag still matches" do
      get "/api/v1/rules_documents"
      etag = response.headers["ETag"]

      get "/api/v1/rules_documents", headers: { "If-None-Match" => etag }

      expect(response).to have_http_status(:not_modified)
    end

    it "serves a fresh response once a document's URL changes" do
      get "/api/v1/rules_documents"
      etag = response.headers["ETag"]

      allow(YAML).to receive(:safe_load_file).and_return(
        [ { "key" => "rulebook", "title" => "Carnevale Rulebook", "url" => "https://example.com/new.pdf" } ]
      )
      get "/api/v1/rules_documents", headers: { "If-None-Match" => etag }

      expect(response).to have_http_status(:ok)
    end
  end

  describe RulesDocument do
    it "rejects a config with duplicate keys, rather than letting two documents share a cache slot" do
      allow(YAML).to receive(:safe_load_file).and_return(
        [
          { "key" => "faq", "title" => "One", "url" => "https://example.com/a.pdf" },
          { "key" => "faq", "title" => "Two", "url" => "https://example.com/b.pdf" }
        ]
      )

      expect { described_class.all }.to raise_error(/Duplicate rules document keys.*faq/)
    end
  end
end
