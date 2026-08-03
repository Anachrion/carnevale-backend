# frozen_string_literal: true

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

require "digest"

# A long-lived, single-use credential the client trades for a fresh access JWT once the short-lived
# JWT expires, so a returning user is re-authenticated silently instead of being bounced to the
# login screen once an hour. It is the durable half of the pair; the JWT is the disposable half.
#
# The opaque token is only ever held by the client. We store its SHA-256 digest, so the row is
# worthless to anyone who reads the database — matching how a password is stored, and unlike the
# short-lived CableTicket whose 30-second exposure doesn't justify hashing.
#
# Tokens are keyed by their own digest, never by user, so one user can hold several at once (phone
# and laptop, each with its own token). Every redemption rotates: the presented token is destroyed
# and a new one issued, so a token that leaks is good for at most one use before the legitimate
# client's next refresh invalidates it.
class RefreshToken < ApplicationRecord
  TTL = 30.days

  belongs_to :user

  # Issues a fresh token for `user` and returns its opaque value (the only time it exists in the
  # clear). Opportunistically prunes expired rows so the table can't grow unbounded from tokens
  # that were minted but never redeemed — e.g. a user who reinstalls the app.
  def self.issue!(user)
    where(expires_at: ..Time.current).delete_all
    raw = SecureRandom.urlsafe_base64(48)
    create!(user: user, token_digest: digest(raw), expires_at: Time.current + TTL)
    raw
  end

  # Redeems `raw_token` exactly once and, if valid, issues its replacement. Returns the user and the
  # new opaque token as `{ user:, token: }`, or nil if the token is unknown, already used, or
  # expired. A row lock makes redemption single-use even if two refreshes race for the same token:
  # the second blocks until the first has deleted the row, then finds nothing.
  def self.rotate(raw_token)
    return if raw_token.blank?

    transaction do
      record = lock.find_by(token_digest: digest(raw_token))
      next nil unless record

      user = record.user
      expired = record.expires_at.past?
      record.destroy!
      next nil if expired

      { user: user, token: issue!(user) }
    end
  end

  # Revokes every refresh token a user holds — used on logout, which signs the user out everywhere
  # rather than leaving other devices' tokens live.
  def self.revoke_all_for(user)
    where(user: user).delete_all
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end
end

# == Schema Information
#
# Table name: refresh_tokens
#
#  id           :bigint           not null, primary key
#  expires_at   :datetime         not null
#  token_digest :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_refresh_tokens_on_expires_at    (expires_at)
#  index_refresh_tokens_on_token_digest  (token_digest) UNIQUE
#  index_refresh_tokens_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
