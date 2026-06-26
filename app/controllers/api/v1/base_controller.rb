module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

      private

      def list_json(list, with_entries: false)
        json = {
          id: list.id,
          name: list.name,
          faction: list.faction,
          points: list.points,
          total_cost: list.list_entries.sum { |e| e.reference.cost }
        }
        if with_entries
          json[:entries] = list.list_entries.includes(:reference).order(:position).map do |entry|
            { id: entry.id, position: entry.position, reference_id: entry.reference_id, name: entry.reference.name, cost: entry.reference.cost }
          end
        end
        json
      end
    end
  end
end
