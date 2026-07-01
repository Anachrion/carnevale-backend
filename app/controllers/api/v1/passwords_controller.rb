module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)

        if successfully_sent?(resource)
          render json: {}, status: :ok
        else
          render json: { errors: resource.errors }, status: :unprocessable_entity
        end
      end

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          render json: { user: user_json(resource) }, status: :ok
        else
          render json: { errors: resource.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_json(user)
        { id: user.id, email: user.email, username: user.username }
      end
    end
  end
end
