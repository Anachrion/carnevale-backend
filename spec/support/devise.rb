# Session-based sign-in helpers for the HTML backoffice request specs (the JSON API uses JWT
# headers instead). Scoped to request/controller specs so API specs are unaffected.
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end
