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
    class RegistrationsController < Devise::RegistrationsController
      include RendersApiErrors
      include AuthenticatesClient
      include SwitchesLocale

      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        build_resource(sign_up_params)
        resource.save

        if resource.persisted?
          render json: { user: UserSerializer.new(resource).as_json }, status: :created
        else
          render_error(resource.errors)
        end
      end

      def update
        if resource.update(account_update_params)
          render json: { user: UserSerializer.new(resource).as_json }, status: :ok
        else
          render_error(resource.errors)
        end
      end

      private

      def account_update_params
        params.require(:user).permit(:username)
      end
    end
  end
end
