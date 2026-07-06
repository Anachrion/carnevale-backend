# One error shape for the whole JSON API: `{ errors: { <attribute> => [messages] } }`.
#
# `render_error` accepts a plain message (filed under `base`), an ActiveModel::Errors, or a
# ready-made hash, so every controller emits the same schema instead of some rendering
# `{ base: [...] }` by hand and others dumping a raw errors object. Included by both the API
# BaseController and the Devise-derived auth controllers, which don't share a base class.
module RendersApiErrors
  extend ActiveSupport::Concern

  private

  def render_error(message_or_errors, status: :unprocessable_entity)
    errors =
      case message_or_errors
      when ActiveModel::Errors then message_or_errors.to_hash
      when Hash then message_or_errors
      else { base: [ message_or_errors ] }
      end
    render json: { errors: errors }, status: status
  end
end
