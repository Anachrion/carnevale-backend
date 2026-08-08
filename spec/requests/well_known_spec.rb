require 'rails_helper'

RSpec.describe "WellKnown", type: :request do
  describe "GET /.well-known/assetlinks.json" do
    around do |example|
      original = ENV["ANDROID_CERT_FINGERPRINTS"]
      example.run
      ENV["ANDROID_CERT_FINGERPRINTS"] = original
    end

    def body
      JSON.parse(response.body)
    end

    # Android fetches this anonymously at install time — no API key, no session. If it ever ends up
    # behind AuthenticatesClient or Devise, verification fails silently and links quietly go back to
    # opening the browser, which is a hard symptom to trace to its cause.
    it "is public and served as JSON" do
      get "/.well-known/assetlinks.json"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
    end

    it "declares the app package with the configured fingerprints" do
      ENV["ANDROID_CERT_FINGERPRINTS"] = "AA:BB:CC, DD:EE:FF"

      get "/.well-known/assetlinks.json"

      expect(body.length).to eq(1)
      statement = body.first
      expect(statement["relation"]).to eq([ "delegate_permission/common.handle_all_urls" ])
      expect(statement["target"]).to include(
        "namespace" => "android_app",
        "package_name" => "app.carnevale.mobile"
      )
      # Several are normal: the Play app-signing certificate, plus the upload certificate for a
      # sideloaded test build. Whitespace around the separator must not leak into the values.
      expect(statement["target"]["sha256_cert_fingerprints"]).to eq([ "AA:BB:CC", "DD:EE:FF" ])
    end

    # Still well-formed when unconfigured, so the endpoint can be inspected in a browser while
    # setting this up; it simply matches nothing, and the controller logs a warning.
    it "serves an empty fingerprint list when none is configured" do
      ENV["ANDROID_CERT_FINGERPRINTS"] = ""

      get "/.well-known/assetlinks.json"

      expect(response).to have_http_status(:ok)
      expect(body.first["target"]["sha256_cert_fingerprints"]).to eq([])
    end

    # Android's verifier follows no redirects: a 301/302 here — from a canonical-host rule, a
    # trailing-slash rule, anything — fails verification outright rather than resolving. The three
    # examples above already prove the exact path routes; this pins that it answers directly.
    it "answers directly rather than redirecting" do
      get "/.well-known/assetlinks.json"

      expect(response).not_to be_redirect
    end
  end
end
