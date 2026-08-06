require 'rails_helper'

# `type: :channel` for the ActionCable test adapter and the have_broadcasted_to matcher — the
# broadcaster isn't a channel itself, it's what pushes onto GameChannel's per-player streams.
RSpec.describe Encounter::GameBroadcaster, type: :channel do
  let(:game) { create(:game) }
  let!(:host) { create(:game_player, game: game, host: true) }
  let!(:guest) { create(:game_player, game: game) }
  let(:spell) { create(:spell, discipline: :runes_of_sovereignty) }
  let(:profile) do
    create(:profile).tap do |p|
      p.replace_granted_spells!([ { grant_kind: "named_spell", consumes_slot: false, resets_each_round: true, spell_id: spell.id } ])
    end
  end
  let(:entry) { create(:list_entry, list: create(:list, owner: host), entry: create(:card_reference, profile: profile)) }
  let!(:entry_state) { create(:entry_state, list_entry: entry, current_life_points: 4) }

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

  describe "#broadcast_entry_state!" do
    # CARNEVALEB-37: the whole point is that the change travels in the payload, so neither client has to
    # re-fetch the player list to discover what moved.
    it "sends both players the changed model's state" do
      expect { described_class.new(game).broadcast_entry_state!(entry_state, owner: host) }
        .to have_broadcasted_to(host).from_channel(GameChannel)
        .with { |payload|
          expect(payload["event"]).to eq("entry_state")
          expect(payload["player_id"]).to eq(host.id)
          expect(payload["list_entry_id"]).to eq(entry.id)
          expect(payload["state"]["life_points"]).to eq("current" => 4, "starting" => 10)
        }

      expect { described_class.new(game).broadcast_entry_state!(entry_state, owner: host) }
        .to have_broadcasted_to(guest).from_channel(GameChannel)
        .with { |payload| expect(payload["list_entry_id"]).to eq(entry.id) }
    end

    # Spell casts don't live in the entry-state payload (deriving `cast` needs each spell's
    # resets_each_round), so they ride along in their own map.
    it "carries each known spell's cast flag" do
      entry_state.update!(spell_casts: { "spell:#{spell.id}" => host.current_turn })

      expect { described_class.new(game).broadcast_entry_state!(entry_state, owner: host) }
        .to have_broadcasted_to(host).from_channel(GameChannel)
        .with { |payload| expect(payload["spell_casts"]).to eq("spell:#{spell.id}" => true) }
    end

    # `activated` and `cast` resolve against the turn of whoever controls the model, not the viewer's
    # — the two players advance turns independently.
    it "resolves the turn-derived flags against the owner's turn, not each viewer's" do
      host.update!(current_turn: 2)
      guest.update!(current_turn: 1)
      entry_state.update!(counters: entry_state.counters.merge("activated_on_turn" => 2))

      expect { described_class.new(game).broadcast_entry_state!(entry_state, owner: host) }
        .to have_broadcasted_to(guest).from_channel(GameChannel)
        .with { |payload| expect(payload["state"]["activated"]).to be true }
    end
  end
end
