# frozen_string_literal: true

class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = "jwt_denylists"

  # A revoked token only needs to be remembered until it would have expired on its own; past that
  # its jti can never match a live token again. Opportunistically drop expired rows whenever a new
  # token is revoked (logout — an infrequent, non-hot path), so the denylist doesn't grow without
  # bound (B-21). Mirrors CableTicket.issue!'s prune. Replicates the strategy's own two-line
  # revoke body (devise-jwt defines it directly on the singleton, so there's no `super` to call).
  def self.revoke_jwt(payload, _user)
    where(exp: ..Time.current).delete_all
    find_or_create_by!(jti: payload["jti"], exp: Time.at(payload["exp"].to_i))
  end
end

# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti) UNIQUE
#
