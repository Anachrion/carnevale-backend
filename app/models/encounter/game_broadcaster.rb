# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
        GameChannel.broadcast_to(game_player, { event: "game_state", game: GameSerializer.new(@game, viewer: game_player).as_json })
      end
    end
  end
end
