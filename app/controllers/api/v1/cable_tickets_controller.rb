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
