require "rails_helper"

# The deep-link landing paths, asserted at the routing layer rather than through a request.
#
# The request spec that exercises them skips whenever public/app/index.html is absent — which is
# always, in CI, since the Flutter bundle is a gitignored build artifact. So a route deleted or
# renamed here would reach production unnoticed: the links would 404 before Flutter ever booted.
# This spec needs no bundle and therefore actually runs.
RSpec.describe "Deep-link landing paths", type: :routing do
  # The reset email links here, and Android claims the path as an App Link (CARNEVALEB-74).
  it "routes /reset-password to the SPA" do
    expect(get: "/reset-password").to route_to("web_app#index")
  end

  it "routes /join to the SPA" do
    expect(get: "/join").to route_to("web_app#index")
  end

  # A shared game setup. The settings ride in the query string, which plays no part in routing —
  # Rails matches the path alone, exactly as Android's intent filter does.
  it "routes /new-game to the SPA, query string and all" do
    expect(get: "/new-game").to route_to("web_app#index")
    expect(get: "/new-game?scenario=Gang+War&ducats=200")
      .to route_to("web_app#index", scenario: "Gang War", ducats: "200")
  end
end
