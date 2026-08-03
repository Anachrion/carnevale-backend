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

# Serves the compiled Flutter web app at the site root.
#
# The bundle lives under public/app with <base href="/app/"> (see bin/release-web), so this returns
# only its entry document at "/", and the browser then loads every asset from /app/* off the static
# file server. Keeping the assets under /app/ is deliberate: a root-based build would place them at
# /assets/ and /canvaskit/, and /assets/ already belongs to Rails' own precompiled backoffice CSS/JS.
#
# The app is public — it runs its own JWT login against the API — so there is no authentication here.
class WebAppController < ApplicationController
  def index
    send_file Rails.root.join("public/app/index.html"), type: "text/html", disposition: "inline"
  end
end
