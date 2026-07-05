module Api
  module V1
    class ListsController < BaseController
      before_action :authenticate_user!
      before_action :set_list, only: %i[show update destroy]

      def index
        # No eager loading here: list_json -> list_entries_for_render loads each list's entries with
        # exactly the associations it needs (incl. the card-reference profiles), so any preload here
        # would just be re-queried and thrown away (B-P2-10).
        render json: current_user.lists.map { |list| list_json(list, with_entries: true) }
      end

      def show
        render json: list_json(@list, with_entries: true)
      end

      def create
        @list = current_user.lists.new(list_params)
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
        @list = current_user.lists.find(params[:id])
      end

      def list_params
        params.require(:list).permit(:name, :faction, :points)
      end
    end
  end
end
