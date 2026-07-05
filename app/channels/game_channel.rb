class GameChannel < ApplicationCable::Channel
  def subscribed
    game_player = current_user.game_players.find_by(game_id: params[:game_id])
    reject and return unless game_player

    # Streamed per game_player (not per game) so each player's broadcast payload can stay
    # scoped to their own private data (drawn agendas) — see Encounter::GameBroadcaster.
    stream_for game_player
    transmit({ event: "game_state", game: GameSerializer.new(game_player.game, viewer: game_player).as_json })
  end
end
