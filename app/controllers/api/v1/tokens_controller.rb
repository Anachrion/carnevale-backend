# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
