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

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Devise's screens are the only ones still drawn by the bare application layout, and they are the
  # first thing anyone sees of the backoffice — so they get one of their own. Backoffice::Base
  # declares layout "backoffice" and overrides this for its own controllers.
  layout -> { devise_controller? ? "auth" : "application" }

  protected

  # Where a visitor lands once Devise considers them signed in — including one who is *already*
  # signed in and asks for the sign-in page again, whom Devise bounces here rather than showing the
  # form twice. Sending them to the backoffice rather than root keeps that bounce off "/", which
  # redirects back to the sign-in page: the round trip that made a loop of it.
  #
  # stored_location_for first, so being challenged for a card deep in the catalog still returns you
  # to that card and not to the index.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || backoffice_profiles_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ])
  end
end
