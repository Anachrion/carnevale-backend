require 'rails_helper'

# Covers the shared client API key enforced by Api::V1::BaseController#authenticate_client!.
# A public catalogue endpoint is used so no user session is involved — the key is a separate
# layer from user authentication.
RSpec.describe "Api::V1 client authentication", type: :request do
  before { create(:spell) }

  context "when API_KEY is configured" do
    let(:api_key) { "s3cret-client-key" }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("API_KEY").and_return(api_key)
    end

    it "rejects a request with no X-Api-Key header" do
      get "/api/v1/spells"

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq("errors" => { "base" => [ "Unauthorized client" ] })
    end

    it "rejects a request with the wrong key" do
      get "/api/v1/spells", headers: { "X-Api-Key" => "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows a request carrying the correct key" do
      get "/api/v1/spells", headers: { "X-Api-Key" => api_key }

      expect(response).to have_http_status(:ok)
    end
  end

  context "when API_KEY is not configured (fail-open)" do
    it "allows the request without any key so local/dev workflows keep working" do
      get "/api/v1/spells"

      expect(response).to have_http_status(:ok)
    end
  end

  # SessionsController/RegistrationsController/PasswordsController extend Devise's controllers, not
  # Api::V1::BaseController, so they need AuthenticatesClient included directly (regression for B-19).
  describe "the Devise-derived auth endpoints" do
    let(:api_key) { "s3cret-client-key" }
    let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }

    context "when API_KEY is configured" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("API_KEY").and_return(api_key)
      end

      it "rejects login with no X-Api-Key header" do
        post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
        expect(response).to have_http_status(:unauthorized)
      end

      it "allows login carrying the correct key" do
        post "/api/v1/login", params: { user: { email: user.email, password: "password123" } },
          headers: { "X-Api-Key" => api_key }
        expect(response).to have_http_status(:ok)
      end

      it "rejects signup with no X-Api-Key header" do
        post "/api/v1/signup", params: { user: { email: "new@example.com", username: "newuser", password: "password123", password_confirmation: "password123" } }
        expect(response).to have_http_status(:unauthorized)
      end

      it "rejects a password reset request with no X-Api-Key header" do
        post "/api/v1/password", params: { user: { email: user.email } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when API_KEY is not configured (fail-open)" do
      it "allows login without any key so local/dev workflows keep working" do
        post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
