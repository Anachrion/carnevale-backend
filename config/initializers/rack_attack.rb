# frozen_string_literal: true

# Rate limiting for the API.
#
# The catalogue endpoints (profiles, equipment, scenarios, spells) are intentionally public — no
# login is required to browse cards — so throttling by IP is the baseline defence against
# scraping, casual abuse, and small request floods. A genuine volumetric DDoS still has to be
# absorbed at the edge (CDN / WAF in front of Thruster); this only protects the application layer.
#
# Counters live in Rails.cache. That is adequate for the current single-container deploy. For a
# multi-node deploy, point `Rack::Attack.cache.store` at a shared store (Redis / solid_cache) so
# limits are enforced across hosts. In the test environment Rails.cache is a null store, so these
# throttles never accumulate and never trip.
class Rack::Attack
  # Paths that must never be throttled (load-balancer / uptime health check).
  UNTHROTTLED_PATHS = [ "/up" ].freeze

  # Auth endpoints where a stricter limit blunts credential stuffing / brute force.
  AUTH_PATHS = [ "/api/v1/login", "/api/v1/signup", "/api/v1/password" ].freeze

  ### Throttles ###

  # General per-IP cap across every request.
  throttle("req/ip",
           limit: Integer(ENV.fetch("THROTTLE_REQ_LIMIT", 300)),
           period: Integer(ENV.fetch("THROTTLE_REQ_PERIOD", 300))) do |req|
    req.ip unless UNTHROTTLED_PATHS.include?(req.path)
  end

  # Tighter per-IP cap on auth endpoints.
  throttle("auth/ip",
           limit: Integer(ENV.fetch("THROTTLE_AUTH_LIMIT", 10)),
           period: Integer(ENV.fetch("THROTTLE_AUTH_PERIOD", 60))) do |req|
    req.ip if AUTH_PATHS.include?(req.path)
  end

  ### Response ###

  # Return a JSON body matching the API's error shape ({ errors: { base: [...] } }), plus a
  # Retry-After header derived from the matched throttle's period.
  self.throttled_responder = lambda do |request|
    period = (request.env.dig("rack.attack.match_data", :period) || 60).to_i
    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => period.to_s
    }
    body = { errors: { base: [ "Too many requests. Please retry later." ] } }.to_json
    [ 429, headers, [ body ] ]
  end
end

Rails.application.config.middleware.use Rack::Attack
