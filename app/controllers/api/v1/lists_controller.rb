module Api
  module V1
    class ListsController < BaseController
      before_action :set_list, only: %i[show update destroy]

      def index
        render json: List.all.map { |list| list_json(list) }
      end

      def show
        render json: list_json(@list, with_entries: true)
      end

      def create
        @list = List.new(list_params)
        if @list.save
          render json: list_json(@list, with_entries: true), status: :created
        else
          render json: { errors: @list.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @list.update(list_params)
          render json: list_json(@list, with_entries: true)
        else
          render json: { errors: @list.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @list.destroy
        head :no_content
      end

      private

      def set_list
        @list = List.find(params[:id])
      end

      def list_params
        params.require(:list).permit(:name, :faction, :points)
      end

      def list_json(list, with_entries: false)
        json = { id: list.id, name: list.name, faction: list.faction, points: list.points }
        if with_entries
          json[:entries] = list.list_entries.order(:position).map do |entry|
            { position: entry.position, reference_id: entry.reference_id, name: entry.reference.name, cost: entry.reference.cost }
          end
        end
        json
      end
    end
  end
end
