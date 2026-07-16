module Api
  module V1
    class BaseController < ActionController::API
      include RendersApiErrors
      include AuthenticatesClient

      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
      # Otherwise an unrescued RecordInvalid (e.g. a create! deep in a service) 500s, and a missing
      # required param returns Rails' default `{status,error}` body — neither is the `{errors:{}}`
      # shape the client parses (B-P2-17). Render both in the API error shape instead.
      rescue_from ActiveRecord::RecordInvalid, with: ->(e) { render_error(e.record.errors) }
      rescue_from ActionController::ParameterMissing, with: ->(e) { render_error(e.message, status: :bad_request) }
    end
  end
end
