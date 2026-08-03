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

# The whole API is consumed only by our own frontends, so require a shared client key on every
# request. It is baked into the frontend builds — a public client can never keep a secret truly
# private, so this only raises the bar against random bots / scrapers / curl; rate limiting
# (Rack::Attack) and CORS are the complementary layers. When API_KEY is unset (development, test,
# and any environment that hasn't opted in) the check is skipped so local workflows keep working;
# set API_KEY to enforce it.
#
# Included by both Api::V1::BaseController and the Devise-derived auth controllers (sessions,
# registrations, passwords), which don't share a base class — mirrors how RendersApiErrors is
# already shared the same way.
#
# DO NOT mark responses `public: true` (in `expires_in` or `stale?`). Thruster sits in front of
# Puma and caches public responses keyed on URL only — X-Api-Key is not part of the cache key.
# The first keyed request would then populate the cache and every later request would be served
# straight from it, never reaching Rails, so this check would never run. That silently made the
# whole read-only catalog fetchable without a key. The catalog controllers therefore use plain
# `expires_in 1.hour` (private): clients still revalidate cheaply via ETag, but no shared cache
# can answer on the app's behalf.
module AuthenticatesClient
  extend ActiveSupport::Concern

  included do
    # Some includers (the Devise-derived auth controllers) don't otherwise pull this in;
    # re-including an already-present module is a no-op.
    include RendersApiErrors
    before_action :authenticate_client!
  end

  private

  def authenticate_client!
    expected = ENV["API_KEY"]
    return if expected.blank?

    provided = request.headers["X-Api-Key"].to_s
    return if ActiveSupport::SecurityUtils.secure_compare(provided, expected)

    render_error("Unauthorized client", status: :unauthorized)
  end
end
