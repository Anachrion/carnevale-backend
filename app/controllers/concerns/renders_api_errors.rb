# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
