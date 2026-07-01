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

      private

      def user_json(user)
        { id: user.id, email: user.email, username: user.username }
      end
    end
  end
end
