require 'rails_helper'

# `type: :channel` for the ActionCable test adapter and the have_broadcasted_to matcher — the
# broadcaster isn't a channel itself, it's what pushes onto GameChannel's per-player streams.
RSpec.describe Encounter::GameBroadcaster, type: :channel do
  let(:game) { create(:game) }
  let!(:host) { create(:game_player, game: game, host: true) }
  let!(:guest) { create(:game_player, game: game) }

  describe "#broadcast_state!" do
    it "sends each player a game_state payload scoped to their own view" do
      expect { described_class.new(game).broadcast_state! }
        .to have_broadcasted_to(host).from_channel(GameChannel)
        .with { |payload| expect(payload["event"]).to eq("game_state") }

      expect { described_class.new(game).broadcast_state! }
        .to have_broadcasted_to(guest).from_channel(GameChannel)
    end

    # A-3: neither Action Cable delivery nor HTTP responses guarantee ordering, so the client
    # orders snapshots by this value. That only works if it advances on every broadcast — a
    # repeated version would let a stale snapshot pass the client's "newer than what I'm showing"
    # check and silently revert the screen.
    it "advances state_version on every broadcast" do
      expect { described_class.new(game).broadcast_state! }
        .to change { game.reload.state_version }.by(1)

      versions = 3.times.map do
        described_class.new(game).broadcast_state!
        game.reload.state_version
      end

      expect(versions).to eq(versions.sort)
      expect(versions.uniq).to eq(versions)
    end

    it "stamps the payload with the version it just bumped to" do
      expect { described_class.new(game).broadcast_state! }
        .to have_broadcasted_to(host).from_channel(GameChannel)
        .with { |payload| expect(payload["game"]["state_version"]).to eq(game.reload.state_version) }
    end

    # Both players order their own snapshots against the same sequence; a version that meant
    # something different per viewer would order nothing.
    it "gives both players the same version for one broadcast" do
      described_class.new(game).broadcast_state!
      before = game.reload.state_version

      expect { described_class.new(game).broadcast_state! }
        .to have_broadcasted_to(guest).from_channel(GameChannel)
        .with { |payload| expect(payload["game"]["state_version"]).to eq(before + 1) }
    end
  end
end
