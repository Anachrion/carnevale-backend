module Api
  module V1
    class EntriesController < BaseController
      before_action :set_list

      def create
        next_position = (@list.list_entries.maximum(:position) || 0) + 1
        entry = @list.list_entries.build(card_reference_id: entry_params[:card_reference_id], position: next_position)
        if entry.save
          render json: list_json(@list.reload, with_entries: true), status: :created
        else
          render json: { errors: entry.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        entry = @list.list_entries.find(params[:id])
        entry.destroy
        render json: list_json(@list.reload, with_entries: true)
      end

      private

      def set_list
        @list = List.find(params[:list_id])
      end

      def entry_params
        params.require(:entry).permit(:card_reference_id)
      end
    end
  end
end
