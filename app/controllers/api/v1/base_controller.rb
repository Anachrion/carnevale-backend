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
          total_cost: list.list_entries.sum { |e| e.card_reference.cost }
        }
        if with_entries
          json[:entries] = list.list_entries.includes(:card_reference).order(:position).map do |entry|
            { id: entry.id, position: entry.position, card_reference_id: entry.card_reference_id, name: entry.card_reference.name, cost: entry.card_reference.cost }
          end
        end
        json
      end
    end
  end
end
