require 'rails_helper'

RSpec.describe "Api::V1::CableTickets", type: :request do
  let(:user) { create(:user) }
  let(:json_headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

  def auth_headers
    post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }.to_json, headers: json_headers
    json_headers.merge("Authorization" => response.headers["Authorization"])
  end

  it "mints a single-use ticket for an authenticated client that redeems to the user" do
    post "/api/v1/cable_tickets", headers: auth_headers

    expect(response).to have_http_status(:created)
    ticket = JSON.parse(response.body)["ticket"]
    expect(ticket).to be_present
    expect(CableTicket.redeem(ticket)).to eq(user)
  end

  it "rejects an unauthenticated request" do
    post "/api/v1/cable_tickets", headers: json_headers

    expect(response).to have_http_status(:unauthorized)
  end
end
