# SPDX-License-Identifier: AGPL-3.0-or-later

module Backoffice
  # The latest changes across the whole catalog — cards, weapons, special rules — and who made them
  # (CARNEVALEB-81). The first place to look when a card turns out broken.
  class HistoryController < BaseController
    # GET /backoffice/history
    def index
      @versions = Catalog::History.recent.includes(:item).to_a
      @authors = Catalog::History.authors(@versions)
    end
  end
end
