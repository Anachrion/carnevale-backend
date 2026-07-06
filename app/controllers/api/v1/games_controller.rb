module Api
  module V1
    class GamesController < BaseController
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
      before_action :ensure_roles_resolved!, only: %i[available_lists select_gang]

      def index
        visibility = params[:visibility] == "archived" ? "archived" : "active"
        # Preload each game's players together with their list and agenda_events so serialization
        # doesn't N+1 over lists, scores, and drawn/held agendas per player (B-P2-4).
        game_players = current_user.game_players
                                   .where(visibility: visibility)
                                   .includes(game: [ :scenario, { game_players: [ :user, :list, :agenda_events ] } ])
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
        if game.save
          game_player = game.game_players.create!(user: current_user, host: true)
          render json: GameSerializer.new(game, viewer: game_player).as_json, status: :created
        else
          render_error(game.errors)
        end
      end

      def show
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def join
        game = Encounter::Game.find_by!(join_code: params[:join_code].to_s.upcase)
        game_player = game.game_players.find_by(user: current_user)

        if game_player
          game_player.update!(visibility: "active") unless game_player.active?
          render json: GameSerializer.new(game, viewer: game_player).as_json
          return
        end

        return render_error("Game is full") if game.game_players.count >= 2

        game_player = game.game_players.create!(user: current_user, host: false)
        game.assign_roll_winners!
        game.update!(status: "gang_selection")
        broadcast_state!(game)
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

        render json: ListSerializer.new(target.list).as_json
      end

      def select_gang
        # Only selectable while the game is still in gang selection; once both players have locked
        # in the game advances past this status and gangs are frozen for the rest of the match.
        return render_error("Gangs can no longer be changed") unless @game.gang_selection?

        list = current_user.lists.find(params[:list_id])
        return render_error("List exceeds this game's ducat limit") if list.points > @game.ducat_limit

        # Re-selecting is allowed during gang selection (a player can change their mind before the
        # game advances). Destroy any previous snapshot first, in a transaction, so we neither leave
        # an orphaned snapshot nor hit the `owner_id NOT NULL` constraint that a bare has_one
        # reassignment would trigger.
        Gang::List.transaction do
          @game_player.list&.destroy!
          @game_player.association(:list).reset
          @game_player.list = list.snapshot_for(@game_player)
        end

        maybe_advance_to_agenda_draw!
        broadcast_state!(@game)
        render json: GameSerializer.new(@game, viewer: @game_player).as_json
      end

      def draw_agendas
        case @game.status
        when "agenda_draw"
          return render_error("Agendas already drawn") if @game_player.drawn_agenda_ids.any?

          # Drawing no longer advances the phase — the player reviews (and optionally mulligans)
          # their hand, then confirms via #confirm_agendas.
          @game.agenda_deck.draw_initial(@game_player)
        when "in_progress"
          return render_error("You've ended the game") if @game_player.finished?
          return render_error("Invalid origin") unless DRAW_ORIGINS.include?(params[:origin])

          @game.agenda_deck.draw(@game_player, origin: params[:origin])
        else
          return render_error("Wrong game status for drawing agendas")
        end

        broadcast_state!(@game)
        # Intentionally narrower than the other game actions (which return the full game): both
        # players already receive the full updated state via broadcast_state!, so the acting player's
        # HTTP response only needs to carry back the delta it asked for — the drawn agendas.
        render json: { agendas: PlayerSerializer.new(@game_player.reload, viewer: @game_player).as_json[:agendas] }
      end

      # The player has reviewed (and optionally mulliganed) their opening hand and is done with the
      # agenda_draw phase. Once both players confirm, the game advances to deploying.
      def confirm_agendas
        return render_error("Wrong game status for confirming agendas") unless @game.agenda_draw?
        return render_error("Draw your agendas first") if @game_player.drawn_agenda_ids.empty?

        @game_player.update!(agendas_confirmed: true)
        maybe_advance_to_deploying!
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

      # Two distinct discards share this endpoint, gated by status:
      #  • the pre-game "mulligan" (origin `unachievable`) — during agenda_draw/deploying a player
      #    tosses an impossible or duplicated agenda and always draws a replacement; and
      #  • in-play discards (special_rule/command_point) while the game is in_progress, which redraw
      #    only when the caller asks (`recycle`).
      def discard_agenda
        origin = params[:origin]
        recycle =
          if @game.mulligan_window? && origin == MULLIGAN_ORIGIN
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

      # Status counters (stunned/hidden/guarding/carrying objective/underwater) on one of the
      # current player's own models — each player only ever edits their own gang. Accepts a
      # partial set of counters; omitted ones keep their current value.
      def update_counters
        update_entry_state! { |state| state.counters = state.counters.merge(counters_params) }
      end

      # Current HP/WP/CP on one of the current player's own models. Accepts a partial set (absolute
      # values, not deltas); omitted stats keep their current value, and none can drop below 0.
      def update_stats
        update_entry_state! do |state|
          stats_params.each { |stat, value| state.public_send("current_#{stat}=", value) }
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

      def ready
        @game_player.update!(ready: true)
        @game.start!
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

      def broadcast_state!(game)
        Encounter::GameBroadcaster.new(game).broadcast_state!
      end

      def ensure_roles_resolved!
        return unless @game.scenario.asymmetric?
        return if @game.game_players.all? { |p| p.role.present? }

        render_error("Role roll-off not resolved yet")
      end

      def maybe_advance_to_agenda_draw!
        return unless @game.status == "gang_selection"
        players = @game.game_players.reload
        return unless players.size == 2 && players.all? { |p| p.list.present? }

        @game.update!(status: "agenda_draw")
      end

      def maybe_advance_to_deploying!
        return unless @game.status == "agenda_draw"
        return unless @game.game_players.reload.all?(&:agendas_confirmed?)

        @game.update!(status: "deploying")
      end

      def recycle_param
        ActiveModel::Type::Boolean.new.cast(params[:recycle])
      end

      # Shared body for the two entry-state PATCH endpoints: gate on status, resolve one of the
      # current player's own models (the opponent's entries 404, since the list is scoped to the
      # requesting player), apply the caller's mutation, then persist and broadcast.
      def update_entry_state!
        return render_error("Wrong game status for updating a model") unless @game.status == "in_progress"

        state = @game_player.list.list_entries.find(params[:list_entry_id]).entry_state
        return render_error("This entry has no state to update") unless state

        yield state
        if state.save
          broadcast_state!(@game)
          # Returns just the mutated entry state, not the whole game: the full state reaches both
          # players via broadcast_state!, and the client applies this slim payload as an optimistic
          # update on the tapped model (see the Flutter _applyEntryState path). Intentional deviation
          # from the game-returning actions — keep it in sync with the client if it ever changes.
          render json: EntryStateSerializer.new(state).as_json
        else
          render_error(state.errors)
        end
      end

      # No type casting: JSON already carries real booleans/integers, and anything else
      # (e.g. "true" as a string) is rejected by EntryState's counters_shape validation.
      def counters_params
        params.require(:counters).permit(*Encounter::EntryState::COUNTER_KEYS).to_h
      end

      def stats_params
        params.require(:stats).permit(:life_points, :will_points, :command_points).to_h
      end
    end
  end
end
