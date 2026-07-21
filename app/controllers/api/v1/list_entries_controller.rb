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
      include AcceptsIdempotencyKey

      before_action :authenticate_user!

      def create
        @list = current_user.lists.find(entry_params[:list_id])
        # Some models can only arrive as another model's companion (the Emissary's Tentacles) — they
        # can't be hired directly. The client hides them from the hire search; this rejects a request
        # that reaches the endpoint anyway (a stale client, or a hand-rolled call).
        return render_error("This model cannot be hired") unless hired_profile_recruitable?

        # Hire the model (idempotently — a flaky client's re-sent hire replays the original row instead
        # of duplicating; a concurrent add that races the position index retries) and add any companions
        # it brings atomically: if the companion sync fails, the whole hire rolls back rather than
        # leaving an orphaned parent (an Emissary with no Tentacles) that would 500 and dirty the gang.
        @list.add_entry_idempotently(
          request_key: idempotency_key,
          entry_type: entry_params[:entry_type],
          entry_id: entry_params[:entry_id]
        ) do |_entry|
          # The gang's effective Leader is pinned to the top; hiring the one that belongs there (a
          # hard Leader, or a lone flex Leader) jumps it up — including when a new hard Leader demotes
          # a flex Leader that was holding the top. Everything else is appended in hire order.
          pin_effective_leader
          # A model that brings companions (the Emissary of Mother Hydra) auto-adds its Tentacles now.
          CompanionSyncService.call(_entry)
        end

        render json: ListSerializer.new(@list.reload).as_json, status: :created
      end

      # Toggles a parent model's optional paid upgrade (the Emissary's +12 Ducats for a second set of
      # Tentacles) and reconciles its companion entries to match. Styled like #illustration / #spells;
      # only the model's own reusable Gang::List is editable (pre-game, in the builder).
      def upgrade
        entry = find_owned_entry
        entry.update!(upgrade_selected: upgrade_params[:upgrade_selected])
        CompanionSyncService.call(entry)
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      def update
        entry = find_owned_entry
        resolution = leader_resolution(entry.list)
        leader = resolution.effective.first
        promotable = resolution.promotable.any? { |e| e.id == entry.id }
        # The effective Leader is pinned to the top and can't be reordered by hand (moving it is a
        # no-op). Nobody else may take position 1 while it holds it — except a *promotable* flex Leader,
        # which is exactly how the player promotes it (it becomes the new Leader, demoting the old one).
        unless leader && entry.id == leader.id
          target = position_params[:position].to_i
          target = target.clamp(2, entry.list.list_entries.count) if leader && !promotable
          ListEntryReorderService.call(entry, target)
        end
        render json: ListSerializer.new(entry.list.reload).as_json
      end

      def destroy
        entry = find_owned_entry
        # A companion (a Tentacle) can't be removed on its own — it leaves only when the model that
        # brought it does. Removing the parent cascades its companions away automatically.
        return render_error("Remove the model that brought it instead") if entry.companion_of_entry_id.present?

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

      # Settles flex-Leader demotion for a list — which entry keeps the Leader keyword, which demote,
      # and which the player could promote — the same LeaderResolver ListSerializer and
      # ListValidationService use, so the three never disagree.
      def leader_resolution(list)
        entries = list.list_entries.where(summoned: false).includes(:entry).to_a
        card_refs = entries.map(&:entry).grep(Catalog::CardReference)
        if card_refs.any?
          ActiveRecord::Associations::Preloader.new(records: card_refs, associations: :profile).call
        end
        ordered = entries.select { |e| e.entry.is_a?(Catalog::CardReference) }.sort_by(&:position)
        LeaderResolver.call(ordered)
      end

      # Moves the gang's effective Leader to position 1 if it isn't already there — run after a hire,
      # so a freshly-added Leader (or a flex Leader that a new hard Leader just demoted past) ends up
      # correctly pinned.
      def pin_effective_leader
        leader = leader_resolution(@list).effective.first
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

      # Whether the model being hired may be recruited directly. Only card-reference hires carry a
      # profile; equipment (and anything without a resolvable profile) is recruitable by default.
      def hired_profile_recruitable?
        return true unless entry_params[:entry_type] == "Catalog::CardReference"

        Catalog::CardReference.find_by(id: entry_params[:entry_id])&.profile&.recruitable? != false
      end

      def entry_params
        params.require(:entry).permit(:list_id, :entry_type, :entry_id)
      end

      def upgrade_params
        params.require(:entry).permit(:upgrade_selected)
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
