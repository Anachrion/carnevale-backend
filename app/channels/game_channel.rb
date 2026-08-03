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
