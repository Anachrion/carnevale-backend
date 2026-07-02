module Api
  module V1
    class ScenariosController < BaseController
      def index
        render json: Scenario.all.map(&:as_json_for_game)
      end
    end
  end
end
