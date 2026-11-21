# SPDX-License-Identifier: AGPL-3.0-or-later

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
