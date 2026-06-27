module Api
  module V1
    class ListsController < BaseController
      before_action :set_list, only: %i[show update destroy]

      def index
        lists = List.all.includes(list_entries: { card_reference: :profile })
        render json: lists.map { |list| list_json(list, with_entries: true) }
      end

      def show
        render json: list_json(@list.tap { |l| l.list_entries.includes(:card_reference).load }, with_entries: true)
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
    end
  end
end
