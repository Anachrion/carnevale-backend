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

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # The client mints a short-lived, single-use ticket over authenticated REST (see CableTicket)
    # and passes it as `?ticket=...`, so the reusable JWT never rides in the WebSocket URL. A leaked
    # ticket is worthless: it is expired within seconds and consumed the moment it is redeemed.
    def find_verified_user
      user = CableTicket.redeem(request.params[:ticket])
      reject_unauthorized_connection if user.nil?
      user
    end
  end
end
