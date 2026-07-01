module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        render json: { user: user_json(resource) }, status: :ok
      end

      def destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        head :no_content
      end

      private

      def user_json(user)
        { id: user.id, email: user.email, username: user.username }
      end
    end
  end
end
