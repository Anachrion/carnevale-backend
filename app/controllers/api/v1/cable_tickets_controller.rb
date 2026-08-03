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
