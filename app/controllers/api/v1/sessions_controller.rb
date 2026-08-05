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

      # Signs this device out, and only this device. Denylisting the JWT (done for us by
      # warden-jwt, since the path is listed in jwt.revocation_requests) kills the access half;
      # revoking the presented refresh token kills the durable half, or the client could silently
      # refresh its way back in.
      #
      # A client that sends no refresh_token falls back to revoking all of them. That is the old
      # behaviour, kept deliberately for builds already in the wild: they clear their local
      # credentials on logout but have no way to name the token they were holding, and leaving it
      # live for the rest of its 30 days would quietly weaken logout for every existing install.
      # Current clients always send it and get the precise behaviour.
      def destroy
        # Read the user before signing out — afterwards there is no current_user to scope by.
        if current_user
          if params[:refresh_token].present?
            RefreshToken.revoke(current_user, params[:refresh_token])
          else
            RefreshToken.revoke_all_for(current_user)
          end
        end
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        head :no_content
      end

      # Signs the user out on every device at once. Separate from #destroy on purpose: revoking
      # every session is destructive enough that it should be something a client asks for by name,
      # not something it triggers by omitting a parameter.
      #
      # Note this drops the durable credentials but cannot denylist the *other* devices' access
      # JWTs — we only ever see the caller's. Those keep working until they expire (an hour at
      # most) and then fail to refresh. Closing that window needs a per-user invalidation
      # timestamp checked at JWT verification; it is not what this endpoint does today.
      def destroy_all
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
