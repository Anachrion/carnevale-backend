require 'rails_helper'

# Covers the Accept-Language -> I18n.locale plumbing in Api::V1::BaseController: the API renders
# its error messages in the language the Flutter client asks for, falling back to English.
RSpec.describe "Api::V1 locale negotiation", type: :request do
  let(:headers) { { "Content-Type" => "application/json" } }

  # A blank username fails ActiveModel presence validation; the message text comes from the locale.
  def signup_with_blank_username(accept_language: nil)
    hdrs = headers.dup
    hdrs["Accept-Language"] = accept_language if accept_language
    params = { user: { username: "", email: "x@example.com", password: "password123", password_confirmation: "password123" } }
    post "/api/v1/signup", params: params.to_json, headers: hdrs
    JSON.parse(response.body).dig("errors", "username") || []
  end

  it "returns English messages by default" do
    messages = signup_with_blank_username
    expect(response).to have_http_status(:unprocessable_entity)
    expect(messages).to include("can't be blank")
  end

  it "returns French messages when the client asks for French" do
    messages = signup_with_blank_username(accept_language: "fr-CA,fr;q=0.9,en;q=0.8")
    expect(response).to have_http_status(:unprocessable_entity)
    expect(messages).to include("doit être rempli(e)")
  end

  it "falls back to English for an unsupported language" do
    messages = signup_with_blank_username(accept_language: "de-DE,de;q=0.9")
    expect(messages).to include("can't be blank")
  end

  it "does not leak a request's locale into a later request on the same thread" do
    signup_with_blank_username(accept_language: "fr")
    messages = signup_with_blank_username # no header -> must be English again
    expect(messages).to include("can't be blank")
  end
end
