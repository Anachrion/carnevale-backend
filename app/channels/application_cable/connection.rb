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
