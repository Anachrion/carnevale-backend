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

      # Replaces the spell selection for a single model: sets its committed Discipline and the exact
      # set of known spells. Validity (Mage-only, one Discipline, spell-count limit) is enforced by
      # ListValidationService and surfaced on the returned list, so an over-limit pick still saves
      # but flips selection_valid to false — mirroring how hiring an illegal model behaves.
      def spells
        entry = find_owned_entry
        Gang::Entry.transaction do
          entry.update!(spell_discipline: spell_params[:discipline].presence)
          entry.entry_spells.destroy_all
          Array(spell_params[:spell_ids]).map(&:to_i).uniq.each do |spell_id|
            entry.entry_spells.create!(spell_id: spell_id)
          end
        end
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

      def spell_params
        params.require(:entry).permit(:discipline, spell_ids: [])
      end
    end
  end
end
