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
    class SessionsController < Devise::SessionsController
      include AuthenticatesClient
      include SwitchesLocale

      skip_before_action :verify_authenticity_token, raise: false
      # Devise guards #destroy with verify_signed_out_user, which looks for a user in the Devise
      # *session*. This API is token-only (store: false), so there never is one, and the guard
      # halts with a bare 401 before the action runs. Skip it and let the action identify the user
      # from the JWT instead — warden-jwt still denylists that JWT via the revocation_request hook.
      skip_before_action :verify_signed_out_user, raise: false
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        # The JWT itself is dispatched into the Authorization header by warden-jwt. Alongside it we
        # hand back a long-lived refresh token in the body so the client can renew the JWT silently
        # once it expires (an hour) instead of forcing a re-login.
        render json: {
          user: UserSerializer.new(resource).as_json,
          refresh_token: RefreshToken.issue!(resource)
        }, status: :ok
      end

      def destroy
        # Read the user before signing out, then drop every refresh token they hold: an explicit
        # logout should revoke the durable credential too, not just denylist the current JWT, or
        # the app could silently refresh its way back in.
        RefreshToken.revoke_all_for(current_user) if current_user
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        head :no_content
      end

      private

      # The API is token-only, so authenticating here must not also open a Devise session.
      # Without `store: false` Warden writes a session cookie, which a browser-based client
      # (Flutter web) then replays on every request — including HTML ones, where it would sign
      # the app user into the backoffice's Devise scope. The JWT is still dispatched: warden-jwt
      # hangs it off `after_set_user`, which runs whether or not the session is stored.
      def auth_options
        super.merge(store: false)
      end
    end
  end
end
