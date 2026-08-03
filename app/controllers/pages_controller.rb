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

# Standalone public pages (privacy policy, account-deletion instructions, and later terms). These
# are the only HTML the site serves besides the Flutter web app at root and the Devise-gated
# backoffice — the Google Play listing links here (privacy policy + account-deletion URL are both
# required for publishing), so the pages carry their own self-contained layout rather than the
# application/backoffice chrome.
class PagesController < ApplicationController
  layout false

  def privacy
  end

  def account_deletion
  end
end
