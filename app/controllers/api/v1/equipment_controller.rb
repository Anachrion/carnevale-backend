# SPDX-License-Identifier: AGPL-3.0-or-later

module Api
  module V1
    class EquipmentController < BaseController
      def index
        scope = Catalog::Equipment.order(:cost, :name)
        return unless stale?(scope)

        expires_in 1.hour
        render json: scope.map { |e|
          { id: e.id, name: e.name, description: e.description, cost: e.cost }
        }
      end
    end
  end
end
