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
          render json: { user: UserSerializer.new(resource).as_json }, status: :ok
        else
          render_error(resource.errors)
        end
      end
    end
  end
end
