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
