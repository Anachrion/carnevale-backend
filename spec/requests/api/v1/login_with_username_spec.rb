require "rails_helper"

RSpec.describe "Api::V1 login with username", type: :request do
  let!(:user) { create(:user, email: "player@example.com", username: "PlayerOne", password: "password123") }

  def login(login_value)
    post "/api/v1/login",
      params: { user: { email: login_value, password: "password123" } }.to_json,
      headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
  end

  it "signs in with the username instead of the email" do
    login("PlayerOne")

    expect(response).to have_http_status(:success)
    expect(response.headers["Authorization"]).to be_present
  end

  it "signs in with the username in a different case" do
    login("playerone")

    expect(response).to have_http_status(:success)
    expect(response.headers["Authorization"]).to be_present
  end

  it "still rejects an unknown login" do
    login("nobody")

    expect(response).to have_http_status(:unauthorized)
  end
end
