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
