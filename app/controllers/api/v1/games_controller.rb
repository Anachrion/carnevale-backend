module Api
  module V1
    class GamesController < BaseController
      DRAW_ORIGINS = %w[special_rule command_point].freeze
      DISCARD_ORIGINS = %w[special_rule command_point].freeze

      before_action :authenticate_user!
      before_action :set_game_and_player, except: %i[index create join]
      before_action :ensure_roles_resolved!, only: %i[available_lists select_gang]

      def index
        visibility = params[:visibility] == "archived" ? "archived" : "active"
        # Preload each game's players together with their list and agenda_events so as_json_for
        # doesn't N+1 over lists, scores, and drawn/held agendas per player (B-P2-4).
        game_players = current_user.game_players
                                   .where(visibility: visibility)
                                   .includes(game: [ :scenario, { game_players: [ :user, :list, :agenda_events ] } ])
        render json: game_players.map { |gp| gp.game.as_json_for(gp) }
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
          render json: game.as_json_for(game_player), status: :created
        else
          render json: { errors: game.errors }, status: :unprocessable_entity
        end
      end

      def show
        render json: @game.as_json_for(@game_player)
      end

      def join
        game = Encounter::Game.find_by!(join_code: params[:join_code].to_s.upcase)
        game_player = game.game_players.find_by(user: current_user)

        if game_player
          game_player.update!(visibility: "active") unless game_player.active?
          render json: game.as_json_for(game_player)
          return
        end

        return render_error("Game is full") if game.game_players.count >= 2

        game_player = game.game_players.create!(user: current_user, host: false)
        game.assign_roll_winners!
        game.update!(status: "gang_selection")
        game.broadcast_state!
        render json: game.as_json_for(game_player)
      end

      def role
        winner = @game.role_roll_winner
        return render_error("Role roll-off not resolved yet") unless winner
        return render_error("Only the roll-off winner picks a role") unless winner.id == @game_player.id
        return render_error("Invalid role") unless @game.assign_paired_choice!(:role, @game_player, params[:role], Encounter::Player::ROLES)

        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def available_lists
        render json: current_user.lists.map { |l| { list: l.as_json_summary, selectable: l.points <= @game.ducat_limit } }
      end

      # Either player's selected gang, in full (with entries) — available for consultation by
      # both participants once that player has picked one, regardless of whose turn it is.
      def player_list
        target = @game.game_players.find(params[:player_id])
        return render_error("List not selected yet") unless target.list.present?

        render json: list_json(target.list, with_entries: true)
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
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def draw_agendas
        case @game.status
        when "agenda_draw"
          return render_error("Agendas already drawn") if @game_player.drawn_agenda_ids.any?

          @game.draw_agendas!(@game_player)
          maybe_advance_to_deploying!
        when "in_progress"
          return render_error("Invalid origin") unless DRAW_ORIGINS.include?(params[:origin])

          @game.draw_agenda!(@game_player, origin: params[:origin])
        else
          return render_error("Wrong game status for drawing agendas")
        end

        @game.broadcast_state!
        render json: { agendas: @game_player.reload.as_json_for(@game_player)[:agendas] }
      end

      def score_agenda
        return render_error("Wrong game status for scoring agendas") unless @game.status == "in_progress"
        return render_error("Agenda not in hand") unless @game.score_agenda!(@game_player, params[:agenda_id].to_i, recycle: recycle_param)

        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def discard_agenda
        return render_error("Wrong game status for discarding agendas") unless @game.status == "in_progress"
        return render_error("Invalid origin") unless DISCARD_ORIGINS.include?(params[:origin])
        return render_error("Agenda not in hand") unless @game.discard_agenda!(@game_player, params[:agenda_id].to_i, origin: params[:origin], recycle: recycle_param)

        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
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

      def advance_turn
        return render_error("Wrong game status for advancing the turn") unless @game.status == "in_progress"

        @game.advance_turn!
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def ready
        @game_player.update!(ready: true)
        @game.start!
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      # Only hides the game from the current user's own game list; the opponent is unaffected.
      def archive
        @game_player.update!(visibility: "archived")
        render json: @game.as_json_for(@game_player)
      end

      def unarchive
        @game_player.update!(visibility: "active")
        render json: @game.as_json_for(@game_player)
      end

      # Soft-deletes the game for the current user only. Once every player has done the same,
      # there's nothing left for either side to see, so the game is hard-deleted.
      def destroy
        @game_player.update!(visibility: "deleted")
        @game.destroy! if @game.game_players.reload.all?(&:deleted?)
        head :no_content
      end

      private

      def set_game_and_player
        @game_player = current_user.game_players.where.not(visibility: "deleted").find_by!(game_id: params[:id])
        @game = @game_player.game
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
        return unless @game.game_players.reload.all? { |p| p.drawn_agenda_ids.any? }

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
          @game.broadcast_state!
          render json: state.as_json_for_display
        else
          render json: { errors: state.errors }, status: :unprocessable_entity
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
