module Api
  module V1
    class GamesController < BaseController
      before_action :authenticate_user!
      before_action :set_game_and_player, except: %i[index create join]
      before_action :ensure_roles_resolved!, only: %i[available_lists select_gang]

      def index
        visibility = params[:visibility] == "archived" ? "archived" : "active"
        game_players = current_user.game_players.where(visibility: visibility).includes(game: [ :scenario, game_players: :user ])
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
        list = current_user.lists.find(params[:list_id])
        return render_error("List exceeds this game's ducat limit") if list.points > @game.ducat_limit

        @game_player.list = list.snapshot_for(@game_player)
        maybe_advance_to_agenda_draw!
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def draw_agendas
        return render_error("Wrong game status for drawing agendas") unless @game.status == "agenda_draw"
        return render_error("Agendas already drawn") if @game_player.agenda_ids.any?

        @game.draw_agendas!(@game_player)
        maybe_advance_to_deploying!
        @game.broadcast_state!
        render json: { agendas: @game_player.reload.as_json_for(@game_player)[:agendas] }
      end

      def ready
        @game_player.update!(ready: true)
        @game.update!(status: "in_progress") if @game.game_players.reload.all?(&:ready)
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
        return unless @game.game_players.reload.all? { |p| p.agenda_ids.any? }

        @game.update!(status: "deploying")
      end
    end
  end
end
