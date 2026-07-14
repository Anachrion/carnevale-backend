module Backoffice
  # Helpers the card itself is drawn with. This file is one of the inputs to
  # Catalog::CardReference.template_digest, so any change here marks every card in the catalog as
  # stale — which is the point when it changes how a card looks, and pure noise when it doesn't.
  # Helpers for the backoffice's own screens belong in CatalogHelper.
  module ProfilesHelper
    # Inline background/text colours for a faction pill in the browse table. The backoffice
    # ships its own small stylesheet rather than Tailwind, so these are plain CSS declarations.
    FACTION_PILL_STYLES = {
      "guild"      => "background:#9b1c1c;color:#fff;",
      "doctors"    => "background:#dbeafe;color:#1e40af;",
      "vatican"    => "background:#fef9c3;color:#854d0e;",
      "gifted"     => "background:#f97316;color:#fff;",
      "rashaar"    => "background:#dcfce7;color:#166534;",
      "patricians" => "background:#6b21a8;color:#fff;",
      "strigoi"    => "background:#1e40af;color:#fff;"
    }.freeze

    def faction_pill_style(faction)
      FACTION_PILL_STYLES.fetch(faction.to_s, "background:#f3f4f6;color:#374151;")
    end

    # The src for an illustration's image: the uploaded file (Active Storage) when there is one,
    # otherwise the committed asset shipped with the app. Both come back as root-relative URLs, so
    # the card renders the same whether its art was uploaded or seeded — and Grover, fetching the
    # page over HTTP, can load either.
    def illustration_src(illustration, faction)
      if illustration.image_attached?
        rails_blob_path(illustration.image, only_path: true)
      else
        asset_path("illustrations/#{faction}/#{illustration.path}")
      end
    end

    # Radial-portrait backing gradient derived from the card's accent colour: rotate the hue
    # 180° and step from a light to a near-black tone so the illustration reads on any faction.
    def illustration_gradient(accent_hex)
      h, _s, _l = hex_to_hsl(accent_hex)
      h_comp = (h + 180) % 360

      light = hsl_to_hex(h_comp, 15, 50)
      mid   = hsl_to_hex(h_comp, 20, 14)
      dark  = hsl_to_hex(h_comp, 15,  3)

      "linear-gradient(150deg,#{light} 0%,#{mid} 45%,#{dark} 85%)"
    end

    private

    def hex_to_hsl(hex)
      r, g, b = hex.delete("#").scan(/../).map { |c| c.to_i(16) / 255.0 }

      max   = [ r, g, b ].max
      min   = [ r, g, b ].min
      delta = max - min
      l     = (max + min) / 2.0
      s     = delta == 0 ? 0.0 : delta / (1 - (2 * l - 1).abs)

      h = if delta == 0
        0.0
      elsif max == r
        60 * (((g - b) / delta) % 6)
      elsif max == g
        60 * ((b - r) / delta + 2)
      else
        60 * ((r - g) / delta + 4)
      end

      [ h, s * 100, l * 100 ]
    end

    def hsl_to_hex(h, s, l)
      s /= 100.0
      l /= 100.0

      c = (1 - (2 * l - 1).abs) * s
      x = c * (1 - ((h / 60.0) % 2 - 1).abs)
      m = l - c / 2.0

      r1, g1, b1 = case h
      when 0...60    then [ c, x, 0 ]
      when 60...120  then [ x, c, 0 ]
      when 120...180 then [ 0, c, x ]
      when 180...240 then [ 0, x, c ]
      when 240...300 then [ x, 0, c ]
      else                [ c, 0, x ]
      end

      "#%02x%02x%02x" % [ ((r1 + m) * 255).round, ((g1 + m) * 255).round, ((b1 + m) * 255).round ]
    end
  end
end
