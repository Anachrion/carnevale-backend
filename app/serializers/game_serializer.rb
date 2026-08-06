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

class GameSerializer
  def initialize(game, viewer:)
    @game = game
    @viewer = viewer
  end

  def as_json
    game = @game
    players = game.game_players.to_a
    # One batched cost query for both players' lists, rather than two aggregate queries per list
    # (which, across the games index, was a per-game N+1 — B-34).
    list_costs = Gang::List.total_costs_for(players.filter_map { |p| p.list&.id })
    {
      id: game.id,
      # Monotonic per game, bumped by GameBroadcaster (A-3). Emitted here rather than only in the
      # broadcast envelope so it rides on *every* Game the client receives — mutation responses and
      # GET /games/:id included. That matters: the widest ordering hazard isn't two broadcasts
      # racing but a mutation response, serialized before the opponent's change committed, landing
      # after the broadcast that carried it. Only a version on both can order them.
      state_version: game.state_version,
      name: game.name,
      join_code: game.join_code,
      status: game.status,
      ducat_limit: game.ducat_limit,
      board_size: game.board_size,
      scenario: ScenarioSerializer.new(game.scenario).as_json,
      viewer_visibility: @viewer&.visibility,
      players: players.map do |gp|
        PlayerSerializer.new(
          gp,
          viewer: @viewer,
          secret: game.scenario.secret_agendas?,
          list_total_cost: gp.list && (list_costs[gp.list.id] || 0)
        ).as_json
      end
    }
  end
end
