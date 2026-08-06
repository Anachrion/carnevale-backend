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

    # Bumps the game's `state_version` and serializes each player's payload *under the same lock*,
    # so the version a payload carries orders it against every other payload of this game (A-3).
    # Doing the two separately would only move the race: two workers could serialize in one order
    # and stamp in the other, which is the thing the version exists to rule out.
    #
    # Delivery is deliberately outside the lock — pushing onto Action Cable is I/O and shouldn't
    # hold a row lock. It also doesn't need to: the client orders by version, not by arrival, so
    # broadcasts may reach it in any order.
    def broadcast_state!
      payloads = @game.with_lock do
        @game.increment!(:state_version)
        @game.game_players.reload.map { |gp| [ gp, GameSerializer.new(@game, viewer: gp).as_json ] }
      end
      payloads.each do |game_player, game|
        GameChannel.broadcast_to(game_player, { event: "game_state", game: game })
      end
    end
  end
end
