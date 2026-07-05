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
