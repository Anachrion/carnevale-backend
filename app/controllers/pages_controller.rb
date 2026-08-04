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
# required for publishing), so the pages share a self-contained layout of their own rather than the
# application/backoffice chrome. See layouts/public_page for what it inlines and why.
class PagesController < ApplicationController
  layout "public_page"

  def privacy
  end

  def account_deletion
  end

  # The printable card sheets. Reads the generated files off disk rather than a table: the PDFs are
  # derived data on the same volume as the card images, and their names carry everything the page
  # shows (faction and generation date), so there is nothing to keep in sync.
  def cards
    @sheets = FactionCardPdf.latest
  end
end
