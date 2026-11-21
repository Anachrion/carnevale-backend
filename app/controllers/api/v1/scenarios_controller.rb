# SPDX-License-Identifier: AGPL-3.0-or-later

module Api
  module V1
    class ScenariosController < BaseController
      def index
        scope = Catalog::Scenario.all
        return unless stale?(scope)

        expires_in 1.hour
        render json: scope.map { |s| ScenarioSerializer.new(s).as_json }
      end
    end
  end
end
