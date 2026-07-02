require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:game) { create(:game) }
  let!(:game_player) { create(:game_player, game: game, user: user) }

  it "subscribes a participant and transmits an initial game_state snapshot" do
    stub_connection current_user: user
    subscribe(game_id: game.id)

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(game_player)
    expect(transmissions.last["game"]["id"]).to eq(game.id)
  end

  it "rejects a user who isn't a participant of the game" do
    stub_connection current_user: other_user
    subscribe(game_id: game.id)

    expect(subscription).to be_rejected
  end
end
