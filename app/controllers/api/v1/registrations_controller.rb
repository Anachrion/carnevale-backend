module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      include RendersApiErrors
      include AuthenticatesClient

      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        build_resource(sign_up_params)
        resource.save

        if resource.persisted?
          render json: { user: UserSerializer.new(resource).as_json }, status: :created
        else
          render_error(resource.errors)
        end
      end

      def update
        if resource.update(account_update_params)
          render json: { user: UserSerializer.new(resource).as_json }, status: :ok
        else
          render_error(resource.errors)
        end
      end

      private

      def account_update_params
        params.require(:user).permit(:username)
      end
    end
  end
end
