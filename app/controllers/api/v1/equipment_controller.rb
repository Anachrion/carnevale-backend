module Api
  module V1
    class EquipmentController < BaseController
      def index
        render json: Equipment.order(:cost, :name).map { |e|
          { id: e.id, name: e.name, description: e.description, cost: e.cost }
        }
      end
    end
  end
end
