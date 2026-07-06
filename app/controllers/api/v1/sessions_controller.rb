module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        render json: { user: UserSerializer.new(resource).as_json }, status: :ok
      end

      def destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        head :no_content
      end
    end
  end
end
