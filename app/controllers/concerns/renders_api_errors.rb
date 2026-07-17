# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
