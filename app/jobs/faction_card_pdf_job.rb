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

# Rebuild every faction's printable PDF (see FactionCardPdf), off the request.
#
# In a job rather than inline in the backoffice action because the whole catalog is ~16 s of image
# decoding and re-encoding on a fast laptop and rather more on the production box — comfortably past
# kamal-proxy's response timeout, so the button that triggered it would report a 502 over work that
# was in fact about to succeed. The publish page shows each sheet's generation date, which is how an
# author sees it land.
class FactionCardPdfJob < ApplicationJob
  queue_as :default

  def perform
    results = FactionCardPdf.generate_all

    results.each do |result|
      if result.ok?
        Rails.logger.info("FactionCardPdfJob wrote #{result.path.basename} " \
                          "(left out #{result.missing} unpublished card(s))")
      else
        Rails.logger.warn("FactionCardPdfJob skipped #{result.faction}: #{result.error}")
      end
    end
  end
end
