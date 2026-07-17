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
