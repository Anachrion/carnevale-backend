module Api
  module V1
    class ScenariosController < BaseController
      def index
        scope = Catalog::Scenario.all
        return unless stale?(scope, public: true)

        expires_in 1.hour, public: true
        render json: scope.map(&:as_json_for_game)
      end
    end
  end
end
