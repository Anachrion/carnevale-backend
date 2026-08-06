require 'rails_helper'

RSpec.describe Encounter::Game, type: :model do
  # A pool wide enough for the initial hands drawn in the advance/start flows.
  def seed_agendas
    %w[1-3 4-6 7-9 10].each { |bucket| create_list(:agenda, 3, first_roll: bucket) }
  end

  def two_players(game)
    host = create(:game_player, game: game, host: true)
    guest = create(:game_player, game: game)
    [host, guest]
  end

  # These tests exercise the concurrency fixes deterministically rather than with real threads:
  # two AR instances of the same game stand in for two simultaneous requests. One instance performs
  # the transition; the other, still holding the *stale* in-memory status the first request saw,
  # then acts — and must reload under the lock and refuse, which is exactly what the row lock buys.

  describe "#join!" do
    let(:game) { create(:game, status: "pending") }

    it "adds a second player and advances the game to gang selection" do
      create(:game_player, game: game, host: true)

      player = game.join!(create(:user))

      expect(player).to be_present
      expect(player).to be_previously_new_record
      expect(game.reload).to be_gang_selection
      expect(game.game_players.count).to eq(2)
    end

    it "reactivates a soft-deleted membership instead of creating a new one" do
      user = create(:user)
      create(:game_player, game: game, host: true)
      returning = create(:game_player, game: game, user: user, visibility: "deleted")

      player = game.join!(user)

      expect(player.id).to eq(returning.id)
      expect(player).to be_active
      expect(player).not_to be_previously_new_record
    end

    it "refuses a third player even when a concurrent join filled the last seat" do
      create(:game_player, game: game, host: true)
      stale = Encounter::Game.find(game.id)         # loaded while only the host is present
      fresh = Encounter::Game.find(game.id)

      fresh.join!(create(:user))                    # the other request takes the second seat

      # `stale` still sees one player in memory; the lock must reload and see the game is full.
      expect(stale.join!(create(:user))).to be_nil
      expect(game.reload.game_players.count).to eq(2)
    end
  end

  describe "#assign_roll_winners!" do
    it "is idempotent — a second call neither reassigns nor trips the winner unique indexes" do
      scenario = create(:scenario, asymmetric: true)
      game = create(:game, scenario: scenario)
      two_players(game)

      game.assign_roll_winners!
      role_winner = game.role_roll_winner
      deployment_winner = game.deployment_roll_winner

      expect { game.assign_roll_winners! }.not_to raise_error
      expect(game.reload.role_roll_winner).to eq(role_winner)
      expect(game.deployment_roll_winner).to eq(deployment_winner)
    end
  end

  describe "#advance_to_agenda_draw_if_ready!" do
    let(:game) { create(:game, status: "gang_selection") }

    before { seed_agendas }

    def select_both_gangs
      host, guest = two_players(game)
      create(:list, owner: host)
      create(:list, owner: guest)
      [host, guest]
    end

    it "deals both opening hands once both players have a gang" do
      host, guest = select_both_gangs

      game.advance_to_agenda_draw_if_ready!

      expect(game.reload).to be_agenda_draw
      [host, guest].each do |p|
        expect(p.agenda_events.where(origin: "initial").count).to eq(game.scenario.agenda_count)
      end
    end

    it "does nothing until both players have selected a gang" do
      host, = two_players(game)
      create(:list, owner: host) # only one gang selected

      expect { game.advance_to_agenda_draw_if_ready! }.not_to change(Encounter::AgendaEvent, :count)
      expect(game.reload).to be_gang_selection
    end

    it "re-checks the reloaded status, so a stale second call can't re-deal (C-3)" do
      select_both_gangs
      stale = Encounter::Game.find(game.id)     # in-memory status is still gang_selection
      Encounter::Game.find(game.id).advance_to_agenda_draw_if_ready! # the winning request deals

      # The losing request must bail on the reloaded agenda_draw status and deal nothing more.
      expect { stale.advance_to_agenda_draw_if_ready! }.not_to change(Encounter::AgendaEvent, :count)
    end
  end

  describe "#start!" do
    let(:game) { create(:game, status: "agenda_draw") }

    def confirmed_players_with_models
      host, guest = two_players(game)
      [host, guest].each do |p|
        p.update!(agendas_confirmed: true)
        list = create(:list, owner: p)
        create(:list_entry, list: list,
               entry: create(:reference, profile: create(:profile, life_points: 10, will_points: 3, command_points: 1)))
      end
      [host, guest]
    end

    it "flips the game live and snapshots one entry state per model once both confirm" do
      confirmed_players_with_models

      expect(game.start!).to be true
      expect(game.reload).to be_in_progress
      expect(Encounter::EntryState.count).to eq(2)
    end

    it "won't start until both players have confirmed" do
      host, = two_players(game)
      host.update!(agendas_confirmed: true) # guest still unconfirmed

      expect(game.start!).to be false
      expect(game.reload).to be_agenda_draw
    end

    it "re-checks the reloaded status, so a stale second confirm can't duplicate entry states (B-6)" do
      confirmed_players_with_models
      stale = Encounter::Game.find(game.id)      # in-memory status is still agenda_draw
      Encounter::Game.find(game.id).start!       # the winning request creates the entry states

      expect(stale.start!).to be false           # loser reloads to in_progress and refuses
      expect(Encounter::EntryState.count).to eq(2)
    end
  end
end

# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  board_size    :string
#  ducat_limit   :integer          not null
#  join_code     :string           not null
#  name          :string           not null
#  state_version :integer          default(0), not null
#  status        :string           default("pending"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  scenario_id   :bigint           not null
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
