# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

      # Repoints a hired model at a different card reference of the *same* profile — i.e. swaps the
      # illustration without changing who the model is. Same-profile references share a cost and
      # stats, so this can't turn one fighter into another; the same-profile guard enforces that.
      # after_commit on Gang::Entry re-validates the list, so the returned payload is current.
      def illustration
        entry = find_owned_entry
        current = entry.entry
        return render_error({ base: [ "This entry has no illustration to change" ] }) unless current.is_a?(Catalog::CardReference)

        target = Catalog::CardReference.find(illustration_params[:entry_id])
        return render_error({ entry_id: [ "must be an illustration of the same model" ] }) unless target.profile_id == current.profile_id

        entry.update!(entry: target)
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

      def illustration_params
        params.require(:entry).permit(:entry_id)
      end
    end
  end
end
