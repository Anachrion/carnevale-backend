module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        render json: { user: UserSerializer.new(resource).as_json }, status: :ok
      end

      def destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        head :no_content
      end

      private

      # The API is token-only, so authenticating here must not also open a Devise session.
      # Without `store: false` Warden writes a session cookie, which a browser-based client
      # (Flutter web) then replays on every request — including HTML ones, where it would sign
      # the app user into the backoffice's Devise scope. The JWT is still dispatched: warden-jwt
      # hangs it off `after_set_user`, which runs whether or not the session is stored.
      def auth_options
        super.merge(store: false)
      end
    end
  end
end
