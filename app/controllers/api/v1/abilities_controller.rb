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
    class AbilitiesController < BaseController
      def index
        scope = Catalog::Ability.all
        scope = scope.where(category: params[:category]) if params[:category].present?
        scope = scope.order(:category, :name)
        return unless stale?(scope)

        expires_in 1.hour
        render json: scope.map { |a| { name: a.name, category: a.category, description: a.description } }
      end
    end
  end
end
