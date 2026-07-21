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
  class Player < ApplicationRecord
    self.table_name = "game_players"

    ROLES = %w[attacker defender].freeze
    VISIBILITIES = %w[active archived deleted].freeze

    belongs_to :game, class_name: "Encounter::Game"
    belongs_to :user
    has_one :list, as: :owner, class_name: "Gang::List", dependent: :destroy
    has_many :agenda_events, class_name: "Encounter::AgendaEvent", foreign_key: "game_player_id", dependent: :destroy

    enum :visibility, VISIBILITIES.index_with(&:itself), default: "active"

    validates :user_id, uniqueness: { scope: :game_id }
    # `role` uses inclusion rather than an `enum` (unlike `visibility` above): it is nullable until
    # the role roll-off resolves, and an out-of-range value coming from the client must surface as a
    # validation error, not the ArgumentError an enum raises on assignment.
    validates :role, inclusion: { in: ROLES }, allow_nil: true

    RESOLVED_ACTIONS = %w[scored discarded].freeze

    # These filter the agenda_events collection in Ruby rather than issuing a WHERE per call, so a
    # preloaded association (e.g. the games index, B-P2-4) resolves them with no extra query; an
    # unloaded one loads the (small, per-player) set once and reuses it.
    # Sorted by event id so the result is in chronological draw order regardless of how the
    # association was loaded (the has_many has no default order clause). The serializer relies on
    # this to keep the hand from re-sorting when an agenda is mulliganed.
    def drawn_agenda_ids
      agenda_events.select { |e| e.action == "drawn" }.sort_by(&:id).map(&:agenda_id)
    end

    def resolved_agenda_ids
      agenda_events.select { |e| RESOLVED_ACTIONS.include?(e.action) }.map(&:agenda_id)
    end

    # Agendas currently held: drawn over the course of the game, minus whichever have since
    # been scored or discarded (an agenda never returns to hand once resolved).
    def hand_agenda_ids
      drawn_agenda_ids - resolved_agenda_ids
    end

    # Every agenda scores a flat 1 Victory Point, so the scored count is the score.
    def score
      agenda_events.count { |e| e.action == "scored" }
    end

    # The turn counter is a per-player, rewindable cursor (not a shared game value): a player can
    # step it back to record a forgotten past-turn score, then forward again, without touching the
    # opponent's view. Agenda events stamp whichever turn the acting player is currently pointed at.
    # Both moves are clamped to [1, scenario.turns] and only allowed while actively playing.
    def advance_turn!
      return false unless playing?
      return false if current_turn >= game.scenario.turns

      update!(current_turn: current_turn + 1)
      true
    end

    def rewind_turn!
      return false unless playing?
      return false if current_turn <= 1

      update!(current_turn: current_turn - 1)
      true
    end

    def on_last_turn?
      current_turn >= game.scenario.turns
    end

    # This player ends the game from their side. Only offered on the final turn. Also archives the
    # game for this player (drops it into their archived list); the opponent is untouched and can
    # keep scoring at their own pace. Game-level completion is then re-derived — under a game-row
    # lock so two players finishing at once serialize: the second reads the first's committed
    # `finished` flag and the game reaches "completed" (unlocked, each read the other's stale
    # pre-commit flag and completion was lost — B-P2-3).
    def finish!
      game.with_lock do
        next false unless game.in_progress? && !finished? && on_last_turn?

        update!(finished: true, visibility: "archived")
        game.refresh_completion!
        true
      end
    end

    # Undo: reopen the game for this player (and un-archive it), reverting game-level completion if
    # the game had completed. Allowed any time this player is finished.
    def unfinish!
      game.with_lock do
        next false unless finished?

        update!(finished: false, visibility: "active")
        game.refresh_completion!
        true
      end
    end

    # Conjures a model onto the board mid-game — a summon/raise granted by some model's special rule.
    # It joins this player's frozen gang snapshot with an entry state of its own, so it takes damage,
    # carries counters and activates exactly like a hired model; but it is flagged `summoned`, which
    # keeps it out of the gang-*building* rules (ducat limit, faction, unique/Leader/ratio — see
    # ListValidationService). Deliberately unrestricted as to *what* can be summoned: the rule lives
    # on the summoner's card and only the player knows what it permits, so the app tracks rather than
    # adjudicates. Returns the new entry, or nil if the player can't act.
    def summon!(card_reference, request_key: nil)
      return nil unless playing? && list

      # Idempotent + position-race-safe, same as a hire (see IdempotentEntries): a re-sent summon
      # replays its row instead of conjuring a second model, and the entry state is created atomically
      # with it. A replay returns the existing entry without re-running the block.
      list.add_entry_idempotently(
        request_key: request_key,
        entry_type: "Catalog::CardReference",
        entry_id: card_reference.id,
        summoned: true
      ) { |entry| Encounter::EntryState.create_for!(entry) }
    end

    # Removes a summoned model — the summon was a mistake, or the rule that sustained it has ended.
    # Only summoned models: the hired roster is frozen the moment the game starts, so a player can't
    # quietly delete a model they're losing with.
    def dismiss_summon!(list_entry)
      return false unless playing?
      return false unless list_entry.summoned?

      list_entry.destroy!
      true
    end

    # Snapshots `list` as this player's frozen gang for the game, replacing any previous pick.
    # Locked on the game row and re-checked against the reloaded status so it can't act on a stale
    # "gang_selection": a select racing the opponent's phase-advancing select would otherwise
    # spawn a second orphaned snapshot (B-P2-4), and the sibling deselect could destroy a list the
    # game has already started depending on (B-P2-2). Destroying the old snapshot first avoids both
    # an orphan and the `owner_id NOT NULL` constraint a bare has_one reassignment would trip.
    # Returns false if gangs are already frozen.
    def select_gang!(list)
      game.with_lock do
        next false unless game.gang_selection?

        self.list&.destroy!
        association(:list).reset
        self.list = list.snapshot_for(self)
        true
      end
    end

    # Clears this player's gang pick, leaving the has_one genuinely empty. Same lock and status
    # re-check as select_gang! (B-P2-2), so it can't destroy a snapshot after the game has advanced.
    def deselect_gang!
      game.with_lock do
        next false unless game.gang_selection?

        self.list&.destroy!
        association(:list).reset
        true
      end
    end

    # Actively taking actions (scoring, drawing, moving the turn cursor): the game is live and this
    # player hasn't ended it. A finished player is soft-locked until they undo.
    def playing?
      game.in_progress? && !finished?
    end
  end
end

# == Schema Information
#
# Table name: game_players
#
#  id                  :bigint           not null, primary key
#  agendas_confirmed   :boolean          default(FALSE), not null
#  current_turn        :integer          default(1), not null
#  finished            :boolean          default(FALSE), not null
#  host                :boolean          default(FALSE), not null
#  role                :string
#  visibility          :string           default("active"), not null
#  won_deployment_roll :boolean          default(FALSE), not null
#  won_role_roll       :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  game_id             :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_game_players_on_game_id                            (game_id)
#  index_game_players_on_game_id_and_user_id                (game_id,user_id) UNIQUE
#  index_game_players_on_game_id_where_won_deployment_roll  (game_id) UNIQUE WHERE won_deployment_roll
#  index_game_players_on_game_id_where_won_role_roll        (game_id) UNIQUE WHERE won_role_roll
#  index_game_players_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#
