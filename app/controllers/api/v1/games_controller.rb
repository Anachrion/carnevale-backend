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
    class GamesController < BaseController
      include AcceptsIdempotencyKey

      # Origins a client may request, derived from the single source of truth on the model so they
      # can't drift. The model's "drawn" list also includes server-internal origins (the opening
      # `initial` draw and `recycle`) that aren't client-initiated, so those are excluded here.
      DRAW_ORIGINS = (Encounter::AgendaEvent::ORIGINS_BY_ACTION.fetch("drawn") - %w[initial recycle]).freeze
      # The mulligan origin (`unachievable`) belongs to the pre-game setup window; the rest are the
      # in-play discards granted by a special rule or command point.
      MULLIGAN_ORIGIN = "unachievable".freeze
      IN_PLAY_DISCARD_ORIGINS = (Encounter::AgendaEvent::ORIGINS_BY_ACTION.fetch("discarded") - [ MULLIGAN_ORIGIN ]).freeze

      before_action :authenticate_user!
      before_action :set_game_and_player, except: %i[index create join]
      before_action :ensure_roles_resolved!, only: %i[available_lists select_gang deselect_gang]

      def index
        visibility = params[:visibility] == "archived" ? "archived" : "active"
        # Preload each game's players together with their list and agenda_events so serialization
        # doesn't N+1 over lists, scores, and drawn/held agendas per player (B-P2-4).
        game_players = current_user.game_players
                                   .where(visibility: visibility)
                                   .includes(game: [ :scenario, { game_players: [ :user, :list, { agenda_events: :agenda } ] } ])
        render json: game_players.map { |gp| GameSerializer.new(gp.game, viewer: gp).as_json }
      end

      def create
        scenario = Catalog::Scenario.find(params[:scenario_id])
        game = Encounter::Game.new(
          scenario: scenario,
          name: params[:name].presence,
          ducat_limit: params[:ducat_limit].presence || scenario.ducats,
          board_size: params[:board_size]
        )
        return render_error(game.errors) unless game.valid?

        # One transaction so a failed host-player insert doesn't leave an orphaned, playerless game
        # (with its join code reserved) behind (B-13). A create! failure rolls back and surfaces as
        # a 422 via the base controller's RecordInvalid handler.
        game_player = nil
        ActiveRecord::Base.transaction do
          game.save!
          game_player = game.game_players.create!(user: current_user, host: true)
        end
        render json: GameSerializer.new(game, viewer: game_player).as_json, status: :created
      end

      def show
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def join
        game = Encounter::Game.find_by!(join_code: params[:join_code].to_s.upcase)
        game_player = game.join!(current_user)
        return render_error("Game is full") unless game_player

        # Only a genuinely new membership advances the game (and needs the opponent notified); a
        # re-join by an existing player just re-serves the current state.
        broadcast_state!(game) if game_player.previously_new_record?
        render json: GameSerializer.new(game, viewer: game_player).as_json
      end

      def role
        winner = @game.role_roll_winner
        return render_error("Role roll-off not resolved yet") unless winner
        return render_error("Only the roll-off winner picks a role") unless winner.id == @game_player.id
        return render_error("Invalid role") unless @game.assign_paired_choice!(:role, @game_player, params[:role], Encounter::Player::ROLES)

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def available_lists
        render json: current_user.lists.map { |l| { list: ListSummarySerializer.new(l).as_json, selectable: l.points <= @game.ducat_limit } }
      end

      # Either player's selected gang, in full (with entries) — available for consultation by
      # both participants once that player has picked one, regardless of whose turn it is.
      def player_list
        target = @game.game_players.find(params[:player_id])
        return render_error("List not selected yet") unless target.list.present?

        render json: player_list_json(target)
      end

      def select_gang
        # Fast pre-check on the in-memory status to reject the common already-advanced case without
        # taking a lock; select_gang! re-checks authoritatively against the reloaded, locked row.
        return render_error("Gangs can no longer be changed") unless @game.gang_selection?

        list = current_user.lists.find(params[:list_id])
        # `points` is only the builder's declared target — guard on what the gang actually costs, so
        # an over-budget gang (e.g. 300 ducats of models in a 150-ducat game) can't freeze into the
        # game (B-12). Roster legality (Leader, ratios, …) is intentionally not enforced here: a
        # player may take a work-in-progress gang into a casual game.
        return render_error("This gang costs more than the game's ducat limit") if list.total_cost > @game.ducat_limit

        return render_error("Gangs can no longer be changed") unless @game_player.select_gang!(list)

        @game.advance_to_agenda_draw_if_ready!
        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def deselect_gang
        # Fast pre-check (see select_gang); deselect_gang! is the authoritative locked guard.
        return render_error("Gangs can no longer be changed") unless @game.gang_selection?
        return render_error("Gangs can no longer be changed") unless @game_player.deselect_gang!

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Only in-play single draws (special_rule/command_point) come through here — the opening hand is
      # dealt automatically the moment the game enters agenda_draw (see #maybe_advance_to_agenda_draw!),
      # since the draw carries no player choice and needs no button.
      def draw_agendas
        return render_error("Wrong game status for drawing agendas") unless @game.in_progress?
        return render_error("You've ended the game") if @game_player.finished?
        return render_error("Invalid origin") unless DRAW_ORIGINS.include?(params[:origin])

        @game.agenda_deck.draw(@game_player, origin: params[:origin])

        broadcast_state!(@game)
        # Intentionally narrower than the other game actions (which return the full game): both
        # players already receive the full updated state via broadcast_state!, so the acting player's
        # HTTP response only needs to carry back the delta it asked for — the drawn agendas.
        render json: { agendas: PlayerSerializer.new(@game_player.reload, viewer: @game_player).as_json[:agendas] }
      end

      # The player has reviewed (and optionally mulliganed) their opening hand and is done with the
      # agenda_draw phase. Once both players confirm, the game goes straight live — deployment is
      # agreed at the table, so there's no in-app deployment step.
      def confirm_agendas
        return render_error("Wrong game status for confirming agendas") unless @game.agenda_draw?

        @game_player.update!(agendas_confirmed: true)
        # No-op unless both players have now confirmed; locked and idempotent (see Game#start!).
        @game.start!
        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def score_agenda
        return render_error("Wrong game status for scoring agendas") unless @game_player.playing?
        # Cycle-driven recycling is decided by the scenario inside AgendaDeck#score, not the client.
        return render_error("Agenda not in hand") unless @game.agenda_deck.score(@game_player, params[:agenda_id].to_i)

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Two kinds of discard share this endpoint:
      #  • the "unachievable" discard (origin `unachievable`) — tossing an impossible or duplicated
      #    agenda and swapping it for a fresh one. Always draws a replacement, whether during the
      #    pre-game mulligan window (agenda_draw) or mid-game (in_progress); and
      #  • in-play discards (special_rule/command_point) while the game is in_progress, which redraw
      #    only when the caller asks (`recycle`).
      def discard_agenda
        origin = params[:origin]
        recycle =
          # The pre-game mulligan closes once this player confirms their hand — otherwise a
          # confirmed player could keep swapping agendas via the API until the opponent confirms
          # (the UI already hides the button, but the server didn't enforce it — B-9). The in-play
          # `unachievable` discard (playing?) is unaffected.
          if origin == MULLIGAN_ORIGIN &&
              ((@game.mulligan_window? && !@game_player.agendas_confirmed?) || @game_player.playing?)
            true
          elsif @game_player.playing? && IN_PLAY_DISCARD_ORIGINS.include?(origin)
            recycle_param
          else
            return render_error("Wrong game status or invalid origin for discarding agendas")
          end

        return render_error("Agenda not in hand") unless @game.agenda_deck.discard(@game_player, params[:agenda_id].to_i, origin: origin, recycle: recycle)

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Conjures a model onto the board mid-game (a summon/raise granted by a special rule) and adds
      # it to this player's gang. Any model in the catalog is allowed: the rule lives on the
      # summoner's card, so the app tracks the summon rather than adjudicating it. The new model is
      # flagged `summoned` and so stays out of the gang-building rules — it neither costs ducats nor
      # invalidates the gang. See Encounter::Player#summon!.
      def summon
        return render_error("Wrong game status for summoning a model") unless @game_player.playing?
        return render_error("You have no gang in this game") unless @game_player.list

        card_reference = Catalog::CardReference.find(params[:card_reference_id])
        # A non-recruitable model (the Emissary's Tentacles) can only arrive with the model that
        # brings it — never summoned on its own. The picker hides them; this rejects a stale request.
        return render_error("This model cannot be summoned") if card_reference.profile&.recruitable? == false
        return render_error("Could not summon that model") unless @game_player.summon!(card_reference, request_key: idempotency_key)

        broadcast_state!(@game)
        render json: player_list_json(@game_player), status: :created
      end

      # Removes a summoned model. Scoped to the player's own list, and Player#dismiss_summon! refuses
      # anything that wasn't summoned — the hired roster is frozen once the game starts.
      def dismiss_summon
        return render_error("Wrong game status for dismissing a model") unless @game_player.playing?
        return render_error("You have no gang in this game") unless @game_player.list

        entry = @game_player.list.list_entries.find(params[:list_entry_id])
        return render_error("Only a summoned model can be removed") unless @game_player.dismiss_summon!(entry)

        broadcast_state!(@game)
        render json: player_list_json(@game_player)
      end

      # Status counters (stunned/hidden/guarding/carrying objective/underwater/activated) on one of
      # the current player's own models — each player only ever edits their own gang. Accepts a
      # partial set of counters; omitted ones keep their current value.
      #
      # `activated` is virtual: it's persisted as the turn the model activated on, stamped from this
      # player's own turn cursor, so it resets itself each turn and can't be forged onto another turn
      # (see Encounter::EntryState#activated?).
      def update_counters
        counters = counters_params
        activated = counters.delete("activated")
        # Never lands in the JSON blob, so counters_shape can't police it the way it does the stored
        # counters — reject a non-boolean here instead, rather than letting "false" activate a model.
        return render_error("activated must be true or false") unless activated.nil? || [ true, false ].include?(activated)

        update_entry_state! do |state|
          state.counters = state.counters.merge(counters)
          state.set_activated(activated, turn: @game_player.current_turn) unless activated.nil?
        end
      end

      # Current HP/WP/CP on one of the current player's own models. Accepts a partial set (absolute
      # values, not deltas); omitted stats keep their current value, and none can drop below 0.
      def update_stats
        update_entry_state! do |state|
          stats_params.each { |stat, value| state.public_send("current_#{stat}=", value) }
        end
      end

      # Marks (or unmarks) one known/granted spell as cast, on one of the current player's own
      # models. `key` identifies the spell ("spell:<id>" or "granted:<id>", see EntrySerializer);
      # `cast` is the desired state rather than a blind toggle, so a retried request from a flaky
      # connection can't accidentally flip it back. Stamped against this player's own turn cursor —
      # see Encounter::EntryState#spell_cast?/#set_spell_cast for how that resets each round, except
      # for a pool/grant that doesn't (Adventuring Noble's Arcane Totem).
      def update_spell_cast
        update_entry_state! do |state|
          state.set_spell_cast(spell_cast_params[:key], cast: spell_cast_params[:cast], turn: @game_player.current_turn)
        end
      end

      # The turn counter is per-player: advance/rewind move only the requesting player's cursor
      # (clamped to [1, scenario.turns]) so one player can correct a past-turn score without moving
      # the other's view. See Encounter::Player#advance_turn!/#rewind_turn!.
      def advance_turn
        return render_error("Can't advance the turn right now") unless @game_player.advance_turn!

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def rewind_turn
        return render_error("Can't rewind the turn right now") unless @game_player.rewind_turn!

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Ends the game from this player's side (only on the final turn) and archives it for them; the
      # opponent keeps playing. `unfinish` undoes it, reopening (and un-archiving) the game.
      def finish
        return render_error("You can only end the game on the final turn") unless @game_player.finish!

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def unfinish
        return render_error("You haven't ended the game") unless @game_player.unfinish!

        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Only hides the game from the current user's own game list; the opponent is unaffected.
      def archive
        @game_player.update!(visibility: "archived")
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def unarchive
        @game_player.update!(visibility: "active")
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      # Soft-deletes the game for the current user only. Once every player has done the same,
      # there's nothing left for either side to see, so the game is hard-deleted. The teardown is
      # serialized with a row lock and the reload happens under it, so two players deleting at once
      # can't both pass the all-deleted check and both call destroy! — the loser would otherwise
      # hit the already-gone row and 500. If the other request won the race, the row is already
      # gone (RecordNotFound), which is exactly the outcome we wanted.
      def destroy
        @game_player.update!(visibility: "deleted")
        @game.with_lock do
          @game.destroy! if @game.game_players.reload.all?(&:deleted?)
        end
        head :no_content
      rescue ActiveRecord::RecordNotFound
        head :no_content
      end

      private

      def set_game_and_player
        @game_player = current_user.game_players.where.not(visibility: "deleted").find_by!(game_id: params[:id])
        @game = @game_player.game
      end

      # A player's gang as the client renders it. `turn` is the *owning* player's cursor, not the
      # viewer's: each player advances turns independently, so a model's `activated` has to resolve
      # against its own controller's turn.
      def player_list_json(player)
        ListSerializer.new(player.list.reload, turn: player.current_turn).as_json
      end

      def broadcast_state!(game)
        Encounter::GameBroadcaster.new(game).broadcast_state!
      end

      def ensure_roles_resolved!
        return unless @game.scenario.asymmetric?
        return if @game.game_players.all? { |p| p.role.present? }

        render_error("Role roll-off not resolved yet")
      end

      def recycle_param
        ActiveModel::Type::Boolean.new.cast(params[:recycle])
      end

      # Shared body for the two entry-state PATCH endpoints: gate on status, resolve one of the
      # current player's own models (the opponent's entries 404, since the list is scoped to the
      # requesting player), apply the caller's mutation, then persist and broadcast.
      def update_entry_state!
        # `playing?` (in_progress AND not finished), so a player who has ended the game can't keep
        # editing their models (B-8) — the draw/score/turn endpoints already block this.
        return render_error("Wrong game status for updating a model") unless @game_player.playing?

        state = @game_player.list.list_entries.find(params[:list_entry_id]).entry_state
        return render_error("This entry has no state to update") unless state

        # Lock the row across the read-modify-write: counters are merged onto the current value, so
        # the same user on two devices would otherwise clobber each other's toggle (B-8).
        saved = false
        state.with_lock do
          yield state
          saved = state.save
        end
        if saved
          broadcast_state!(@game)
          # Returns just the mutated entry state, not the whole game: the full state reaches both
          # players via broadcast_state!, and the client applies this slim payload as an optimistic
          # update on the tapped model (see the Flutter _applyEntryState path). Intentional deviation
          # from the game-returning actions — keep it in sync with the client if it ever changes.
          render json: EntryStateSerializer.new(state, turn: @game_player.current_turn).as_json
        else
          render_error(state.errors)
        end
      end

      # No type casting: JSON already carries real booleans/integers, and anything else
      # (e.g. "true" as a string) is rejected by EntryState's counters_shape validation.
      def counters_params
        params.require(:counters).permit(*Encounter::EntryState::CLIENT_COUNTER_KEYS).to_h
      end

      def stats_params
        params.require(:stats).permit(:life_points, :will_points, :command_points).to_h
      end

      def spell_cast_params
        params.require(:spell_cast).permit(:key, :cast)
      end
    end
  end
end
