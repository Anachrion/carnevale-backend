module Encounter
  # Pushes the current game state to each connected player over ActionCable. Broadcasts per
  # game_player (not once per game) so each player's payload can stay scoped to their own private
  # data (drawn agendas). Extracted so the transport concern lives here rather than in the
  # Encounter::Game domain model (B-P2-7).
  class GameBroadcaster
    def initialize(game)
      @game = game
    end

    def broadcast_state!
      @game.game_players.reload.each do |game_player|
        GameChannel.broadcast_to(game_player, { event: "game_state", game: @game.as_json_for(game_player) })
      end
    end
  end
end
