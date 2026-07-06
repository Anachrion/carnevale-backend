module Api
  module V1
    class BaseController < ActionController::API
      include RendersApiErrors

      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

      # The whole API is consumed only by our own frontends, so require a shared client key on
      # every request. It is baked into the frontend builds — a public client can never keep a
      # secret truly private, so this only raises the bar against random bots / scrapers / curl;
      # rate limiting (Rack::Attack) and CORS are the complementary layers. When API_KEY is unset
      # (development, test, and any environment that hasn't opted in) the check is skipped so
      # local workflows keep working; set API_KEY to enforce it.
      before_action :authenticate_client!

      private

      def authenticate_client!
        expected = ENV["API_KEY"]
        return if expected.blank?

        provided = request.headers["X-Api-Key"].to_s
        return if ActiveSupport::SecurityUtils.secure_compare(provided, expected)

        render_error("Unauthorized client", status: :unauthorized)
      end
    end
  end
end
