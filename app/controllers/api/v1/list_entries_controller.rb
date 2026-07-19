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
          # The gang's effective Leader is pinned to the top; hiring the one that belongs there (a
          # hard Leader, or a lone flex Leader) jumps it up — including when a new hard Leader demotes
          # a flex Leader that was holding the top. Everything else is appended in hire order.
          pin_effective_leader
          render json: ListSerializer.new(@list.reload).as_json, status: :created
        else
          render_error(entry.errors)
        end
      end

      def update
        entry = find_owned_entry
        leader = effective_leader_entry(entry.list)
        # The effective Leader is pinned to the top and can't be reordered by hand: moving it is a
        # no-op, and no other model may take position 1 while it holds it. Everything below the Leader
        # (including a demoted flex Leader) reorders freely.
        unless leader && entry.id == leader.id
          target = position_params[:position].to_i
          target = target.clamp(2, entry.list.list_entries.count) if leader
          ListEntryReorderService.call(entry, target)
        end
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      def destroy
        entry = find_owned_entry
        entry.destroy
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      # Replaces the spell selection for a single model, one pool at a time: sets each pool's
      # committed Discipline(s) and the exact set of known spells picked from it. Validity (Mage-only,
      # each pool's Discipline(s)/slot limit) is enforced by ListValidationService and surfaced on the
      # returned list, so an over-limit pick still saves but flips selection_valid to false —
      # mirroring how hiring an illegal model behaves.
      #
      # Rejected once this entry's game has gone past the agenda_draw phase (see #spell_edits_locked?)
      # — the rulebook picks spells "at the start of the game," not mid-battle.
      def spells
        entry = find_owned_entry_for_spells
        if spell_edits_locked?(entry.list)
          return render_error({ base: [ "Spells are locked in for this game — confirming your Agendas locks them together" ] })
        end

        # Defer validation across the destroy_all + N creates per pool so the whole spell edit
        # re-validates the list once, at the end, instead of once per child callback (B-P2-6).
        Gang::List.defer_validation do
          Gang::Entry.transaction do
            # Apprentice Doctor's Apprenticeship only — omitted for every other profile's edits, so
            # a plain pool_selections PATCH never has to know or care about this field.
            entry.update!(mentored_by_entry_id: spell_params[:mentored_by_entry_id]) if spell_params.key?(:mentored_by_entry_id)
            entry.entry_pool_disciplines.destroy_all
            entry.entry_spells.destroy_all
            Array(spell_params[:pool_selections]).each do |selection|
              pool_id = selection[:pool_id].to_i
              Array(selection[:disciplines]).uniq.each do |discipline|
                entry.entry_pool_disciplines.create!(pool_id: pool_id, discipline: discipline)
              end
              Array(selection[:spell_ids]).map(&:to_i).uniq.each do |spell_id|
                entry.entry_spells.create!(pool_id: pool_id, spell_id: spell_id)
              end
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

      # The entry that keeps the Leader keyword once flex-Leader demotion is resolved — the hard
      # Leader if any is fielded, else a lone flex Leader — and so the one pinned to the top of the
      # list. Mirrors ListValidationService#effective_leader_refs. Nil when the gang holds no Leader.
      # (Equipment carries no profile, so it's never a Leader.)
      def effective_leader_entry(list)
        leaders = list.list_entries.order(:position).select do |e|
          e.profile&.keywords&.include?("Leader")
        end
        return nil if leaders.empty?

        leaders.reject { |e| e.profile.flexible_leader }.first || leaders.first
      end

      # Moves the gang's effective Leader to position 1 if it isn't already there — run after a hire,
      # so a freshly-added Leader (or a flex Leader that a new hard Leader just demoted past) ends up
      # correctly pinned.
      def pin_effective_leader
        leader = effective_leader_entry(@list)
        ListEntryReorderService.call(leader, 1) if leader && leader.position != 1
      end

      def find_owned_entry
        Gang::Entry.joins(:list).where(lists: { owner_type: "User", owner_id: current_user.id }).find(params[:id])
      end

      # Every other action here only ever touches a player's own reusable Gang::List (owner: User)
      # — you don't reorder, remove, or re-skin a model mid-game, only pre-game in the builder.
      # Spells are the one exception: the rulebook picks them "at the start of the game," so this
      # also has to reach the per-game snapshot (owner: Encounter::Player) created at gang-selection
      # time, right up until it locks (see #spell_edits_locked?).
      def find_owned_entry_for_spells
        entry = Gang::Entry.joins(:list).find(params[:id])
        raise ActiveRecord::RecordNotFound unless owns_list?(entry.list)

        entry
      end

      def owns_list?(list)
        case list.owner
        when User then list.owner_id == current_user.id
        when Encounter::Player then list.owner.user_id == current_user.id
        else false
        end
      end

      def entry_params
        params.require(:entry).permit(:list_id, :entry_type, :entry_id)
      end

      def position_params
        params.require(:entry).permit(:position)
      end

      def spell_params
        params.require(:entry).permit(:mentored_by_entry_id, pool_selections: [ :pool_id, disciplines: [], spell_ids: [] ])
      end

      # A spell edit is locked once this list's owning Encounter::Player has confirmed their Agendas
      # — the same single gate the pre-game "Ready" button uses for both (see Encounter::Game#start!).
      # A player's own reusable Gang::List (owner: User, not yet selected for any game) is never
      # locked.
      def spell_edits_locked?(list)
        player = list.owner
        player.is_a?(Encounter::Player) && player.agendas_confirmed?
      end

      def illustration_params
        params.require(:entry).permit(:entry_id)
      end
    end
  end
end
