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

class PlayerSerializer
  # `secret` reflects the scenario's Secret agenda rule (passed down by GameSerializer). It only
  # affects how much of an *opponent's* agendas a viewer sees — a player always sees all of their own.
  def initialize(player, viewer:, secret: false, list_total_cost: nil)
    @player = player
    @viewer = viewer
    @secret = secret
    @list_total_cost = list_total_cost
  end

  def as_json
    player = @player
    viewing_self = @viewer&.id == player.id
    {
      id: player.id,
      user_id: player.user_id,
      username: player.user.username,
      host: player.host,
      list: player.list && ListSummarySerializer.new(player.list, total_cost: @list_total_cost).as_json,
      role: player.role,
      agendas_confirmed: player.agendas_confirmed,
      won_role_roll: player.won_role_roll,
      won_deployment_roll: player.won_deployment_roll,
      score: player.score,
      current_turn: player.current_turn,
      finished: player.finished,
      # Hand agendas are open information by default (rulebook: "all players can see other players'
      # Agendas"); the Secret rule keeps them hidden from the opponent until achieved. Either way a
      # player always sees their own hand.
      agendas: hand_visible?(viewing_self) ? hand_agendas : [],
      agenda_history: visible_history(viewing_self)
    }
  end

  private

  def hand_visible?(viewing_self)
    viewing_self || !@secret
  end

  def visible_history(viewing_self)
    events = agenda_history
    return events if viewing_self || !@secret

    # Secret scenario, opponent's view: reveal only resolved events (scored/discarded). Scored
    # agendas are shown because the rule keeps them secret only "until achieved"; discarded ones
    # are shown so the opponent can agree they were unachievable. Dropping `drawn` events also
    # keeps the still-secret hand from leaking through the history.
    events.select { |e| Encounter::Player::RESOLVED_ACTIONS.include?(e[:action]) }
  end

  # Ordered by when each agenda entered the hand (draw order), not by agenda id. `where(id: ...)`
  # would return rows in primary-key order, so mulliganing one agenda would re-sort the whole hand
  # around its replacement — confusing mid-review. Keeping draw order leaves the untouched agendas
  # in place and drops the redraw at the bottom.
  def hand_agendas
    ids = @player.hand_agenda_ids
    # Resolve from the agendas already preloaded on this player's events, rather than a fresh
    # `Catalog::Agenda.where` per player (B-34).
    by_id = sorted_events.map(&:agenda).uniq.index_by(&:id)
    ids.filter_map { |id| by_id[id] }.map { |a| { id: a.id, name: a.name, description: a.description } }
  end

  def agenda_history
    sorted_events.map do |event|
      {
        turn: event.turn,
        action: event.action,
        origin: event.origin,
        caused_by_event_id: event.caused_by_event_id,
        agenda: { id: event.agenda.id, name: event.agenda.name }
      }
    end
  end

  # Sort the preloaded agenda_events in Ruby (by draw order) instead of an `.order` on the
  # association, which would re-query and discard the preload (B-34). Memoized per serializer.
  def sorted_events
    @sorted_events ||= @player.agenda_events.sort_by { |e| [ e.turn, e.id ] }
  end
end
