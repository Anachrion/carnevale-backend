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
    class PasswordsController < Devise::PasswordsController
      include RendersApiErrors
      include AuthenticatesClient
      include SwitchesLocale

      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)

        if successfully_sent?(resource)
          render json: {}, status: :ok
        else
          render_error(resource.errors)
        end
      end

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          # A completed reset is an authentication: the caller proved control of the account's inbox
          # and has just chosen the password. Sign in so warden-jwt dispatches a JWT (the reset path
          # is listed in jwt.dispatch_requests) and hand back a refresh token beside it, exactly as
          # login does — the client can then land on the account screen already signed in instead of
          # asking for the password it just set.
          #
          # `store: false` for the same reason as SessionsController#create: a stored Devise session
          # would set a cookie that a browser-based client replays onto HTML requests, signing the
          # app user into the backoffice scope. The JWT still ships, because warden-jwt hangs off
          # `after_set_user`, which runs either way.
          # Credentials handed out under the old password must not outlive it. Without this, every
          # refresh token issued before the reset stayed valid for the rest of its 30 days — so
          # resetting your password because someone else knew it did not actually lock them out.
          # Revoke first, then issue: the new token below belongs to the caller who just proved
          # control of the account's inbox, and must survive.
          RefreshToken.revoke_all_for(resource)

          sign_in(resource_name, resource, store: false)

          render json: {
            user: UserSerializer.new(resource).as_json,
            refresh_token: RefreshToken.issue!(resource)
          }, status: :ok
        else
          render_error(resource.errors)
        end
      end
    end
  end
end
