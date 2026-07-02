module Api
  module V1
    class GamesController < BaseController
      before_action :authenticate_user!
      before_action :set_game_and_player, except: %i[index create join]
      before_action :ensure_roles_resolved!, only: %i[available_lists select_gang]

      def index
        games = current_user.games.includes(:scenario, game_players: :user)
        render json: games.map { |g| g.as_json_for(g.game_players.find { |p| p.user_id == current_user.id }) }
      end

      def create
        scenario = Scenario.find(params[:scenario_id])
        game = Game.new(
          scenario: scenario,
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
        game = Game.find_by!(join_code: params[:join_code].to_s.upcase)
        game_player = game.game_players.find_by(user: current_user)

        if game_player
          render json: game.as_json_for(game_player)
          return
        end

        return render_error("Game is full") if game.game_players.count >= 2

        game_player = game.game_players.create!(user: current_user, host: false)
        game.update!(status: "gang_selection")
        game.broadcast_state!
        render json: game.as_json_for(game_player)
      end

      def role_roll
        return render_error("Scenario is not asymmetric") unless @game.scenario.asymmetric?
        return render_error("Role already decided") if @game.role_roll_winner_id.present?

        @game.roll!(:role, @game_player)
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def role
        return render_error("Role roll-off not resolved yet") unless @game.role_roll_winner_id
        return render_error("Only the roll-off winner picks a role") unless @game.role_roll_winner_id == @game_player.id
        return render_error("Invalid role") unless @game.assign_paired_choice!(:role, @game_player, params[:role], GamePlayer::ROLES)

        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def available_lists
        render json: current_user.lists.map { |l| { list: list_json(l), selectable: l.points <= @game.ducat_limit } }
      end

      def select_gang
        list = current_user.lists.find(params[:list_id])
        return render_error("List exceeds this game's ducat limit") if list.points > @game.ducat_limit

        @game_player.update!(list: list)
        maybe_advance_to_agenda_draw!
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def draw_agendas
        return render_error("Wrong game status for drawing agendas") unless @game.status == "agenda_draw"
        return render_error("Agendas already drawn") if @game_player.agenda_ids.any?

        @game.draw_agendas!(@game_player)
        maybe_advance_to_deployment_rolloff!
        @game.broadcast_state!
        render json: { agendas: @game_player.reload.as_json_for(@game_player)[:agendas] }
      end

      def deployment_roll
        return render_error("Wrong game status for the deployment roll-off") unless @game.status == "deployment_rolloff"
        return render_error("Deployment zone already decided") if @game.deployment_roll_winner_id.present?

        @game.roll!(:deployment, @game_player)
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def deployment_zone
        return render_error("Deployment roll-off not resolved yet") unless @game.deployment_roll_winner_id
        return render_error("Only the roll-off winner picks a zone") unless @game.deployment_roll_winner_id == @game_player.id
        return render_error("Invalid zone") unless @game.assign_paired_choice!(:deployment_zone, @game_player, params[:zone], GamePlayer::DEPLOYMENT_ZONES)

        @game.update!(status: "deploying")
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      def ready
        @game_player.update!(ready: true)
        @game.update!(status: "in_progress") if @game.game_players.reload.all?(&:ready)
        @game.broadcast_state!
        render json: @game.as_json_for(@game_player)
      end

      private

      def set_game_and_player
        @game_player = current_user.game_players.find_by!(game_id: params[:id])
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
        return unless players.size == 2 && players.all? { |p| p.list_id.present? }

        @game.update!(status: "agenda_draw")
      end

      def maybe_advance_to_deployment_rolloff!
        return unless @game.status == "agenda_draw"
        return unless @game.game_players.reload.all? { |p| p.agenda_ids.any? }

        @game.update!(status: "deployment_rolloff")
      end
    end
  end
end
