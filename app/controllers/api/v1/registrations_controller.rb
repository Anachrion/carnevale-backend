module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        build_resource(sign_up_params)
        resource.save

        if resource.persisted?
          render json: { user: user_json(resource) }, status: :created
        else
          render json: { errors: resource.errors }, status: :unprocessable_entity
        end
      end

      def update
        if resource.update(account_update_params)
          render json: { user: user_json(resource) }, status: :ok
        else
          render json: { errors: resource.errors }, status: :unprocessable_entity
        end
      end

      private

      def account_update_params
        params.require(:user).permit(:username)
      end

      def user_json(user)
        { id: user.id, email: user.email, username: user.username }
      end
    end
  end
end
