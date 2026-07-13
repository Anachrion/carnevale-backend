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
    # keep scoring at their own pace. Game-level completion is then re-derived.
    def finish!
      return false unless game.in_progress? && !finished? && on_last_turn?

      transaction do
        update!(finished: true, visibility: "archived")
        game.refresh_completion!
      end
      true
    end

    # Undo: reopen the game for this player (and un-archive it), reverting game-level completion if
    # the game had completed. Allowed any time this player is finished.
    def unfinish!
      return false unless finished?

      transaction do
        update!(finished: false, visibility: "active")
        game.refresh_completion!
      end
      true
    end

    # Conjures a model onto the board mid-game — a summon/raise granted by some model's special rule.
    # It joins this player's frozen gang snapshot with an entry state of its own, so it takes damage,
    # carries counters and activates exactly like a hired model; but it is flagged `summoned`, which
    # keeps it out of the gang-*building* rules (ducat limit, faction, unique/Leader/ratio — see
    # ListValidationService). Deliberately unrestricted as to *what* can be summoned: the rule lives
    # on the summoner's card and only the player knows what it permits, so the app tracks rather than
    # adjudicates. Returns the new entry, or nil if the player can't act.
    def summon!(card_reference)
      return nil unless playing? && list

      transaction do
        entry = list.list_entries.create!(
          entry_type: "Catalog::CardReference",
          entry_id: card_reference.id,
          position: (list.list_entries.maximum(:position) || 0) + 1,
          summoned: true
        )
        Encounter::EntryState.create_for!(entry)
        entry
      end
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
