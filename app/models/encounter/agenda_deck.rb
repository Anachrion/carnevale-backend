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

module Encounter
  # The agenda-deck subsystem for a game: the initial batch draw, single in-play draws, and
  # scoring/discarding (each of which can trigger a "recycle" replacement draw). Extracted from
  # Encounter::Game, which had grown to own this whole concern on top of its lifecycle/roll-off
  # responsibilities (B-P2-7). Reach it via `game.agenda_deck`.
  class AgendaDeck
    # Buckets repeated to weight the draw toward the lower rolls (the "1-3"/"4-6"/"7-9" ranges each
    # appear three times, "10" once), mirroring the physical d10 agenda table.
    BUCKET_WEIGHTS = %w[1-3 1-3 1-3 4-6 4-6 4-6 7-9 7-9 7-9 10].freeze

    def initialize(game)
      @game = game
    end

    # The initial hand each player draws at the start of the agenda-draw phase. Idempotent: skips a
    # player who already holds an "initial" draw, so a repeated/raced advance-to-agenda-draw can't
    # deal a second opening hand (the phase transition is also locked — see Game, C-3/B-P2).
    def draw_initial(game_player)
      return if game_player.agenda_events.exists?(origin: "initial")

      count = @game.scenario.agenda_count
      drawn = []
      drawn << draw_one(drawn) while drawn.size < count
      drawn.each do |agenda_id|
        game_player.agenda_events.create!(agenda_id: agenda_id, action: "drawn", origin: "initial", turn: game_player.current_turn)
      end
    end

    # Single card draw during play (as opposed to the initial batch), e.g. granted by a special
    # rule, a command point ability, or as the replacement half of a "Cycle" scenario rule
    # (origin: "recycle", caused_by_event: the score/discard that triggered it).
    def draw(game_player, origin:, caused_by_event: nil)
      raise ArgumentError, "origin must not be \"initial\" outside the initial draw" if origin == "initial"

      agenda_id = draw_one(game_player.drawn_agenda_ids)
      game_player.agenda_events.create!(agenda_id: agenda_id, action: "drawn", origin: origin, caused_by_event: caused_by_event, turn: game_player.current_turn)
    end

    # Scoring is worth a flat 1 VP. When the scenario carries the "Cycle" rule, scoring immediately
    # draws a replacement (rulebook: "When you score Victory Points for an Agenda, immediately draw
    # another one") — driven by the scenario rather than a client flag so it can't be misreported.
    def score(game_player, agenda_id)
      return false unless game_player.hand_agenda_ids.include?(agenda_id)

      # The scored event and its Cycle-rule replacement draw are one unit: if the replacement raises
      # (e.g. deck exhausted), roll the score back too, rather than leave a scored-but-not-broadcast
      # event that a retry then rejects as "not in hand" (B-7).
      ActiveRecord::Base.transaction do
        event = game_player.agenda_events.create!(agenda_id: agenda_id, action: "scored", turn: game_player.current_turn)
        draw(game_player, origin: "recycle", caused_by_event: event) if @game.scenario.cycle_agendas?
      end
      true
    end

    def discard(game_player, agenda_id, origin:, recycle: false)
      return false unless game_player.hand_agenda_ids.include?(agenda_id)

      # Discard + optional replacement draw are atomic, for the same reason as #score (B-7).
      ActiveRecord::Base.transaction do
        event = game_player.agenda_events.create!(agenda_id: agenda_id, action: "discarded", origin: origin, turn: game_player.current_turn)
        draw(game_player, origin: "recycle", caused_by_event: event) if recycle
      end
      true
    end

    private

    def draw_one(already_drawn)
      # Try weighted buckets first. Sample in Ruby rather than `ORDER BY RANDOM() LIMIT 1`: identical
      # SQL for a repeated bucket is served from the per-request query cache, which would return the
      # same row every time. Bound the attempts so an exhausted pool can't spin forever (B-P2-9).
      BUCKET_WEIGHTS.size.times do
        bucket = BUCKET_WEIGHTS.sample
        candidates = Catalog::Agenda.where(first_roll: bucket).pluck(:id) - already_drawn
        return candidates.sample if candidates.any?
      end

      # Weighted buckets kept coming up empty — fall back to any undrawn agenda regardless of
      # bucket (nil only if the entire deck has been drawn, which the callers never do).
      Catalog::Agenda.where.not(id: already_drawn).pluck(:id).sample
    end
  end
end
