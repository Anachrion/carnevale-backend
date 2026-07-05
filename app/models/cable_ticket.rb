# frozen_string_literal: true

# A short-lived, single-use credential for opening an ActionCable connection without putting the
# reusable JWT in the WebSocket URL (which lands in access/proxy/monitoring logs). The client
# authenticates normally over REST (JWT in the Authorization header) to mint one, then connects
# with `?ticket=<token>`; even if that URL leaks into a log the ticket is already expired/consumed.
#
# Tickets are keyed by their own random token, never by user, so a single user can hold several at
# once — e.g. the same game open on a phone and a laptop, each with its own connection.
class CableTicket < ApplicationRecord
  TTL = 30.seconds

  belongs_to :user

  # Issues a fresh ticket for `user` and returns its opaque token. Opportunistically prunes expired
  # rows so the table can't grow unbounded from tickets that were minted but never redeemed.
  def self.issue!(user)
    where(expires_at: ..Time.current).delete_all
    token = SecureRandom.urlsafe_base64(32)
    create!(user: user, token: token, expires_at: Time.current + TTL)
    token
  end

  # Redeems `token` exactly once and returns its user, or nil if the token is unknown, already
  # used, or expired. A row lock makes redemption single-use even if two connects race for the same
  # ticket: the second blocks until the first has deleted the row, then finds nothing.
  def self.redeem(token)
    return if token.blank?

    transaction do
      ticket = lock.find_by(token: token)
      next nil unless ticket

      ticket.destroy!
      ticket.expires_at.future? ? ticket.user : nil
    end
  end
end

# == Schema Information
#
# Table name: cable_tickets
#
#  id         :bigint           not null, primary key
#  expires_at :datetime         not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_cable_tickets_on_expires_at  (expires_at)
#  index_cable_tickets_on_token       (token) UNIQUE
#  index_cable_tickets_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
