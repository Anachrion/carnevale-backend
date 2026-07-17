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
    class CableTicketsController < BaseController
      before_action :authenticate_user!

      # Mints a short-lived, single-use ticket the client swaps in for the JWT when opening the
      # ActionCable WebSocket, so the reusable token never travels in the (loggable) WS URL. The
      # request itself is authenticated the normal way (JWT in the Authorization header).
      def create
        render json: { ticket: CableTicket.issue!(current_user) }, status: :created
      end
    end
  end
end
