require "rails_helper"

# A failed login is the path every client walks down eventually, and nothing covered it: the specs
# only signed in successfully. Devise decides between "redirect to the sign-in page" and "401 JSON"
# from navigational_formats, which used to include '*/*' — so a client that sent no Accept header
# was served the HTML sign-in page and a 422, rather than an error it could read.
RSpec.describe "Api::V1 login failures", type: :request do
  let!(:user) { create(:user, email: "player@example.com", password: "password123") }

  def login(password:, headers: {})
    post "/api/v1/login",
      params: { user: { email: user.email, password: password } }.to_json,
      headers: { "Content-Type" => "application/json" }.merge(headers)
  end

  it "answers a wrong password with 401 and a JSON error" do
    login(password: "wrong", headers: { "Accept" => "application/json" })

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["error"]).to be_present
  end

  it "answers in JSON even when the client sends no Accept header" do
    login(password: "wrong", headers: { "Accept" => "*/*" })

    expect(response).to have_http_status(:unauthorized)
    expect(response.media_type).to eq("application/json")
    expect(response.body).not_to include("<html")
  end

  it "still signs a real user in" do
    login(password: "password123", headers: { "Accept" => "application/json" })

    expect(response).to have_http_status(:success)
    expect(response.headers["Authorization"]).to be_present
  end

  # The other half of navigational_formats: a browser must still get the page, not JSON.
  it "leaves the browser sign-in page rendering HTML" do
    post user_session_path, params: { user: { email: user.email, password: "wrong" } },
      headers: { "Accept" => "text/html" }

    expect(response.media_type).to eq("text/html")
    expect(response.body).to include("Sign in to continue")
  end
end
