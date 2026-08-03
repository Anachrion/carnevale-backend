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

module Api
  module V1
    # Trades a valid refresh token for a fresh access JWT. This is the one authenticated-ish
    # endpoint that must NOT require a live JWT — the whole point is to be reachable once the JWT
    # has expired — so it inherits only the shared X-Api-Key client check from BaseController and
    # authenticates the caller by the refresh token in the body instead.
    class TokensController < BaseController
      # Signing the user in below fires warden-jwt's dispatch hook, which mints a fresh JWT into the
      # Authorization response header — but only because POST /api/v1/token is listed in
      # `config.jwt.dispatch_requests` (config/initializers/devise.rb), exactly like /login.
      def create
        result = RefreshToken.rotate(params[:refresh_token])

        unless result
          render_error("Invalid or expired refresh token", status: :unauthorized)
          return
        end

        # store: false keeps this from opening a Devise cookie session; the JWT is dispatched
        # regardless, since warden-jwt hangs off `after_set_user`. Mirrors SessionsController.
        sign_in(result[:user], store: false)
        render json: {
          user: UserSerializer.new(result[:user]).as_json,
          refresh_token: result[:token]
        }, status: :ok
      end
    end
  end
end
