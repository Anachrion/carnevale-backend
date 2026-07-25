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

# Standalone public pages (privacy policy, and later terms). These are the only HTML the site
# serves besides the Flutter web app at root and the Devise-gated backoffice — the Google Play
# listing links here for the privacy policy, so the pages carry their own self-contained layout
# rather than the application/backoffice chrome.
class PagesController < ApplicationController
  layout false

  def privacy
  end
end
