# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
