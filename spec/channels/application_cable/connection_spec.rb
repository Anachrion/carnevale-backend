require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  it "identifies the user from a valid ticket and consumes it" do
    token = CableTicket.issue!(user)

    connect params: { ticket: token }

    expect(connection.current_user).to eq(user)
    # The ticket was single-use — redeeming it again (e.g. a second connection) finds nothing.
    expect(CableTicket.redeem(token)).to be_nil
  end

  it "rejects a connection with a missing or invalid ticket" do
    expect { connect params: { ticket: "bogus" } }.to have_rejected_connection
    expect { connect }.to have_rejected_connection
  end
end
