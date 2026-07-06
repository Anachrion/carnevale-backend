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
          render json: ListSerializer.new(@list.reload).as_json, status: :created
        else
          render_error(entry.errors)
        end
      end

      def update
        entry = find_owned_entry
        ListEntryReorderService.call(entry, position_params[:position].to_i)
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      def destroy
        entry = find_owned_entry
        entry.destroy
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      # Replaces the spell selection for a single model: sets its committed Discipline and the exact
      # set of known spells. Validity (Mage-only, one Discipline, spell-count limit) is enforced by
      # ListValidationService and surfaced on the returned list, so an over-limit pick still saves
      # but flips selection_valid to false — mirroring how hiring an illegal model behaves.
      def spells
        entry = find_owned_entry
        # Defer validation across the update + destroy_all + N creates so the whole spell edit
        # re-validates the list once, at the end, instead of once per child callback (B-P2-6).
        Gang::List.defer_validation do
          Gang::Entry.transaction do
            entry.update!(spell_discipline: spell_params[:discipline].presence)
            entry.entry_spells.destroy_all
            Array(spell_params[:spell_ids]).map(&:to_i).uniq.each do |spell_id|
              entry.entry_spells.create!(spell_id: spell_id)
            end
          end
        end
        entry.list.refresh_selection_validity
        render json: ListSerializer.new(entry.list.reload).as_json
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
