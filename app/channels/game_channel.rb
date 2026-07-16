class GameChannel < ApplicationCable::Channel
  def subscribed
    # Exclude soft-deleted memberships, matching the REST authorization boundary
    # (Api::V1::GamesController#set_game_and_player) — a player who deleted the game shouldn't keep
    # receiving its broadcasts (B-10).
    game_player = current_user.game_players.where.not(visibility: "deleted").find_by(game_id: params[:game_id])
    reject and return unless game_player

    # Streamed per game_player (not per game) so each player's broadcast payload can stay
    # scoped to their own private data (drawn agendas) — see Encounter::GameBroadcaster.
    stream_for game_player
    transmit({ event: "game_state", game: GameSerializer.new(game_player.game, viewer: game_player).as_json })
  end
end
