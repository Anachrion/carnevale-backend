require "rails_helper"

# The Flutter web bundle (public/app) is a build artifact produced by bin/release-web and gitignored,
# so it is absent in CI. Only assert when it has actually been built locally; skip otherwise.
RSpec.describe "Web app SPA", type: :request do
  before do
    skip "web bundle not built (public/app/index.html missing)" unless
      Rails.root.join("public/app/index.html").exist?
  end

  # The password-reset email and game-join links point at absolute paths (/reset-password, /join)
  # that must serve the SPA entry document so the Flutter app can boot and route client-side from
  # window.location. Without these routes those URLs 404 before Flutter loads.
  it "serves the SPA entry document at root and the deep-link landing paths" do
    ["/", "/reset-password?reset_password_token=abc123", "/join?code=XYZ"].each do |path|
      get path
      expect(response).to have_http_status(:ok), "expected 200 for #{path}, got #{response.status}"
      expect(response.content_type).to start_with("text/html")
    end
  end
end
