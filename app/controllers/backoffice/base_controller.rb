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

module Backoffice
  # Shared base for the Devise-gated card-authoring backoffice.
  #
  # The card renderer works by having Grover (headless Chrome) navigate back to our own
  # `card` action to screenshot it. That internal request carries no Devise session, so it
  # would otherwise be bounced to the login page. To let only the render endpoint through we
  # accept a stable render token (derived from secret_key_base, so there's nothing extra to
  # configure) in place of a logged-in user. Everything else still requires authentication.
  class BaseController < ApplicationController
    layout "backoffice"

    before_action :authenticate_backoffice!

    # Stable per-app secret shared between the controller and the Grover URLs it builds.
    def self.render_token
      Digest::SHA256.hexdigest("card-render:#{Rails.application.secret_key_base}")
    end

    private

    # The json list columns (a profile's keywords and abilities, a weapon's abilities) are edited
    # as one-per-line textareas — the forms' only concession to their shape, and cheaper to use
    # than a row of nested fields.
    def text_to_list(text)
      text.to_s.split("\n").map(&:strip).compact_blank
    end

    # Backoffice is admin-only. App users authenticate via the JWT API and are not admins; the
    # HTML Devise session here must belong to a User with admin? true. (The render token still
    # bypasses this for Grover's internal card fetch.)
    def authenticate_backoffice!
      return if valid_render_token?
      return authenticate_user! unless user_signed_in?
      return if current_user.admin?

      render plain: "Forbidden — backoffice access requires an admin account.", status: :forbidden
    end

    # A render-token request is only ever the internal Grover fetch of a card page, so it is
    # limited to that one action — otherwise the token (a permanent, unrotatable secret derived
    # from secret_key_base) would also open every other backoffice GET, including full-catalog
    # PDF/PNG export.
    def valid_render_token?
      action_name == "card" &&
        request.get? &&
        params[:render_token].present? &&
        ActiveSupport::SecurityUtils.secure_compare(params[:render_token], self.class.render_token)
    end
  end
end
