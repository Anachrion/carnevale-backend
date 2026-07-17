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
    class RegistrationsController < Devise::RegistrationsController
      include RendersApiErrors
      include AuthenticatesClient

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
