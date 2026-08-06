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

    # Pushes one model's changed state (counters, stats, tokens, spell casts) rather than the whole
    # game. `game_state` carries nothing entry-derived, so a counter toggle used to broadcast a
    # payload identical to the last one and the client had no choice but to re-fetch the full player
    # list to find what changed — four HTTP round-trips across the table per tap (CARNEVALEB-37). This event
    # carries the change itself, so nobody re-fetches anything.
    #
    # Unscoped by viewer: a gang and its models are open information (both players can already GET
    # either player's list), so both get the same payload. `turn` is the *owner's* cursor, since
    # `activated` and `cast` resolve against the turn of whoever controls the model.
    def broadcast_entry_state!(entry_state, owner:)
      entry = entry_state.list_entry
      payload = {
        event: "entry_state",
        player_id: owner.id,
        list_entry_id: entry.id,
        state: EntryStateSerializer.new(entry_state, turn: owner.current_turn).as_json,
        spell_casts: EntrySerializer.new(entry, cantrips: cantrips, turn: owner.current_turn).spell_cast_flags
      }
      @game.game_players.reload.each { |game_player| GameChannel.broadcast_to(game_player, payload) }
    end

    private

    def cantrips
      Catalog::Spell.cantrips.index_by(&:discipline)
    end
  end
end
