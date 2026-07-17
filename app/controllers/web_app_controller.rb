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
