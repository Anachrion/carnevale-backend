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
    class BaseController < ActionController::API
      include RendersApiErrors
      include AuthenticatesClient

      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
      # Otherwise an unrescued RecordInvalid (e.g. a create! deep in a service) 500s, and a missing
      # required param returns Rails' default `{status,error}` body — neither is the `{errors:{}}`
      # shape the client parses (B-P2-17). Render both in the API error shape instead.
      rescue_from ActiveRecord::RecordInvalid, with: ->(e) { render_error(e.record.errors) }
      rescue_from ActionController::ParameterMissing, with: ->(e) { render_error(e.message, status: :bad_request) }
    end
  end
end
