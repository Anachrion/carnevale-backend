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
  class Game < ApplicationRecord
    STATUSES = %w[pending gang_selection agenda_draw in_progress completed].freeze

    belongs_to :scenario, class_name: "Catalog::Scenario"

    has_many :game_players, class_name: "Encounter::Player", dependent: :destroy

    enum :status, STATUSES.index_with(&:itself), default: "pending"

    validates :ducat_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :join_code, presence: true, uniqueness: true
    validates :name, presence: true

    before_validation :generate_join_code, on: :create
    before_validation :default_name_to_scenario, on: :create

    # Adds `user` as the second player, or reactivates their soft-deleted/archived membership.
    # Locked on the game row so two people racing the same join code can't both pass the
    # "full" check and create a third player (B-P2): the reload under the lock sees the other
    # request's committed player. Returns the resulting Player, or nil when the game is already
    # full for a newcomer. A freshly created player reports `previously_new_record?` so the caller
    # knows whether the game actually advanced (and needs broadcasting).
    def join!(user)
      with_lock do
        existing = game_players.find_by(user: user)
        if existing
          existing.update!(visibility: "active") unless existing.active?
          existing
        elsif game_players.count >= 2
          nil
        else
          player = game_players.create!(user: user, host: false)
          assign_roll_winners!
          update!(status: "gang_selection")
          player
        end
      end
    end

    # Picks the roll-off winners as soon as both players are in the game, so nothing depends on
    # a client action: deployment_roll_winner is always assigned (shown for reference; the
    # deployment zone itself is chosen at the table, not in-app), role_roll_winner only for
    # asymmetric scenarios (where it matters). Idempotent — skips a roll whose winner is already
    # set — so a retried/raced join can call it again without reassigning or hitting the partial
    # unique indexes on the winner flags.
    def assign_roll_winners!
      players = game_players.reload.to_a
      return unless players.size == 2

      players.sample.update!(won_role_roll: true) if scenario.asymmetric? && players.none?(&:won_role_roll?)
      players.sample.update!(won_deployment_roll: true) if players.none?(&:won_deployment_roll?)
    end

    # Deals both opening agenda hands the instant gang selection completes, and only then. Locked
    # and re-checked against the reloaded status so a second select_gang racing the first can't
    # re-run the deal on a stale "gang_selection" (which double-dealt every hand — C-3);
    # draw_initial is itself idempotent as a second line of defence.
    def advance_to_agenda_draw_if_ready!
      with_lock do
        next unless gang_selection?

        players = game_players.reload
        next unless players.size == 2 && players.all? { |p| p.list.present? }

        update!(status: "agenda_draw")
        players.each { |p| agenda_deck.draw_initial(p) }
      end
    end

    def role_roll_winner
      game_players.find(&:won_role_roll?)
    end

    def deployment_roll_winner
      game_players.find(&:won_deployment_roll?)
    end

    # Winner's choice is assigned to `chooser`; the complementary option is auto-assigned to the
    # other player. Used for the attacker/defender role pick.
    def assign_paired_choice!(attribute, chooser, chosen, options)
      return false unless options.include?(chosen)

      other = game_players.find { |p| p.id != chooser.id }
      chooser.update!(attribute => chosen)
      other.update!(attribute => (options - [ chosen ]).first)
      true
    end

    # The setup window in which a player may mulligan an impossible/duplicated agenda (discard +
    # redraw): the agenda_draw phase, where each player reviews their opening hand. Once both players
    # confirm, the game goes straight live (in_progress) and the mulligan window closes.
    def mulligan_window?
      agenda_draw?
    end

    # The agenda-deck subsystem (initial/in-play draws, scoring, discarding). Lives in its own
    # service object rather than on the model (B-P2-7).
    def agenda_deck
      @agenda_deck ||= AgendaDeck.new(self)
    end

    # Called once both players have confirmed their opening Agenda hand — flips the game live and
    # snapshots each model's HP/WP/CP into an Encounter::EntryState. Locked and re-checked against
    # the reloaded status so two players confirming at once can't both pass the guard and have the
    # loser 500 on duplicate entry states (B-P2-6): the second call reloads, sees in_progress, and
    # returns false. Also makes a repeated confirm a harmless no-op. Deployment zones are agreed at
    # the table, so there's no separate in-app deployment step.
    def start!
      with_lock do
        next false if in_progress? || completed?
        next false unless game_players.reload.all?(&:agendas_confirmed?)

        update!(status: "in_progress")
        create_entry_states!
        true
      end
    end

    # Completion is derived from the players' per-player `finished` flags rather than driven by the
    # turn counter: the game is `completed` only once both players have ended it, and reverts to
    # `in_progress` the moment either undoes (so one player finishing never ends it for the other).
    # Called after any finish/unfinish; a no-op outside the in-play phases.
    def refresh_completion!
      return unless in_progress? || completed?

      all_finished = game_players.reload.all?(&:finished?)
      if all_finished && !completed?
        update!(status: "completed")
      elsif !all_finished && completed?
        update!(status: "in_progress")
      end
    end

    private

    # Equipment entries have no profile (no HP/WP/CP), so only card-reference entries — i.e.
    # actual models — get an entry state.
    def create_entry_states!
      game_players.each do |gp|
        next unless gp.list

        # Filtered to card references, so preloading the nested profile is safe (no Equipment in
        # the set) and spares create_for! a profile lookup per model (B-P2-1).
        entries = gp.list.list_entries.where(entry_type: "Catalog::CardReference").includes(entry: :profile)
        entries.each { |list_entry| Encounter::EntryState.create_for!(list_entry) }
      end
    end

    def generate_join_code
      self.join_code ||= loop do
        code = SecureRandom.alphanumeric(6).upcase
        break code unless Game.exists?(join_code: code)
      end
    end

    def default_name_to_scenario
      self.name = scenario.name if name.blank? && scenario
    end
  end
end

# == Schema Information
#
# Table name: games
#
#  id          :bigint           not null, primary key
#  board_size  :string
#  ducat_limit :integer          not null
#  join_code   :string           not null
#  name        :string           not null
#  status      :string           default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  scenario_id :bigint           not null
#
# Indexes
#
#  index_games_on_join_code    (join_code) UNIQUE
#  index_games_on_scenario_id  (scenario_id)
#
# Foreign Keys
#
#  fk_rails_...  (scenario_id => scenarios.id)
#
