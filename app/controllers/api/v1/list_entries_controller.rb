module Api
  module V1
    class ListEntriesController < BaseController
      before_action :authenticate_user!

      def create
        @list = current_user.lists.find(entry_params[:list_id])
        next_position = (@list.list_entries.maximum(:position) || 0) + 1
        entry = @list.list_entries.build(entry_type: entry_params[:entry_type], entry_id: entry_params[:entry_id], position: next_position)
        if entry.save
          ListSortingService.call(@list)
          render json: list_json(@list.reload, with_entries: true), status: :created
        else
          render json: { errors: entry.errors }, status: :unprocessable_entity
        end
      end

      def update
        entry = find_owned_entry
        ListEntryReorderService.call(entry, position_params[:position].to_i)
        render json: list_json(entry.list.reload, with_entries: true)
      end

      def destroy
        entry = find_owned_entry
        entry.destroy
        render json: list_json(entry.list.reload, with_entries: true)
      end

      private

      def find_owned_entry
        Gang::Entry.joins(:list).where(lists: { owner_type: "User", owner_id: current_user.id }).find(params[:id])
      end

      def entry_params
        params.require(:entry).permit(:list_id, :entry_type, :entry_id)
      end

      def position_params
        params.require(:entry).permit(:position)
      end
    end
  end
end
