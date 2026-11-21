# SPDX-License-Identifier: AGPL-3.0-or-later

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
