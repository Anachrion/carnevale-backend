module Api
  module V1
    class BaseController < ActionController::API
      include RendersApiErrors
      include AuthenticatesClient

      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
    end
  end
end
