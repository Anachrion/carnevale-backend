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
          total_cost: list.list_entries.sum(&:cost),
          selection_valid: list.selection_valid,
          selection_errors: list.selection_errors
        }
        if with_entries
          json[:entries] = list.list_entries.includes(:entry).order(:position).map do |list_entry|
            { id: list_entry.id, position: list_entry.position, entry_type: list_entry.entry_type, entry_id: list_entry.entry_id, name: list_entry.entry.name, cost: list_entry.cost }
          end
        end
        json
      end
    end
  end
end
