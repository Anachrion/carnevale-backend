require 'rails_helper'

RSpec.describe Encounter::Player, type: :model do
  # A two-turn scenario keeps the "last turn" boundary close for the finish/clamp cases.
  def in_progress_game(turns: 2)
    scenario = create(:scenario, turns: turns)
    create(:game, scenario: scenario, status: "in_progress")
  end

  describe "the turn cursor" do
    it "advances and rewinds only within [1, scenario.turns]" do
      game = in_progress_game(turns: 2)
      player = create(:game_player, game: game)

      expect(player.rewind_turn!).to be false # already at 1
      expect(player.current_turn).to eq(1)

      expect(player.advance_turn!).to be true
      expect(player.current_turn).to eq(2)

      expect(player.advance_turn!).to be false # already at the last turn
      expect(player.current_turn).to eq(2)

      expect(player.rewind_turn!).to be true
      expect(player.current_turn).to eq(1)
    end

    it "won't move while the game isn't in progress or the player has finished" do
      pending_game = create(:game, status: "deploying")
      expect(create(:game_player, game: pending_game).advance_turn!).to be false

      game = in_progress_game(turns: 1)
      finished = create(:game_player, game: game, finished: true)
      expect(finished.advance_turn!).to be false
      expect(finished.rewind_turn!).to be false
    end
  end

  describe "finishing" do
    it "is only allowed on the last turn, and archives the game for that player" do
      game = in_progress_game(turns: 2)
      player = create(:game_player, game: game)

      expect(player.finish!).to be false # not on the last turn yet
      player.advance_turn!
      expect(player.finish!).to be true
      expect(player).to have_attributes(finished: true, visibility: "archived")
    end

    it "unfinishing reopens and un-archives for that player" do
      game = in_progress_game(turns: 1)
      player = create(:game_player, game: game, finished: true, visibility: "archived")

      expect(player.unfinish!).to be true
      expect(player).to have_attributes(finished: false, visibility: "active")
      expect(player.unfinish!).to be false # nothing to undo
    end
  end

  describe "game completion derived from both players" do
    it "completes only when both finish, and reverts when either undoes" do
      game = in_progress_game(turns: 1)
      host = create(:game_player, game: game, host: true)
      guest = create(:game_player, game: game)

      host.finish!
      expect(game.reload.status).to eq("in_progress") # guest still playing

      guest.finish!
      expect(game.reload.status).to eq("completed")

      host.unfinish!
      expect(game.reload.status).to eq("in_progress")
    end
  end
end
