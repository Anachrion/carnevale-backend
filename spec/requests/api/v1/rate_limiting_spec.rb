require 'rails_helper'

# Covers the Rack::Attack throttling that protects the (partly public) API.
#
# In the test environment Rails.cache is a null store, so throttle counters never accumulate. To
# exercise the behaviour we give Rack::Attack a real (memory) store and swap in a tiny-limit
# throttle, restoring both afterwards so no global state leaks between examples.
RSpec.describe "Api::V1 rate limiting", type: :request do
  before do
    create(:spell)

    @original_store = Rack::Attack.cache.store
    @original_throttles = Rack::Attack.throttles.dup

    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.throttles.clear
    Rack::Attack.throttle("test/req/ip", limit: 2, period: 60) { |req| req.ip }
  end

  after do
    Rack::Attack.throttles.replace(@original_throttles)
    Rack::Attack.cache.store = @original_store
  end

  it "serves requests under the limit and returns 429 once it is exceeded" do
    2.times do
      get "/api/v1/spells"
      expect(response).to have_http_status(:ok)
    end

    get "/api/v1/spells"

    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers["Retry-After"]).to eq("60")
    expect(JSON.parse(response.body)).to eq("errors" => { "base" => [ "Too many requests. Please retry later." ] })
  end
end
