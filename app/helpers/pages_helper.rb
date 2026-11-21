# SPDX-License-Identifier: AGPL-3.0-or-later

# Helpers for the standalone public pages (see PagesController).
module PagesHelper
  # A faction's own colour, as it appears on the cards themselves and in the app.
  #
  # These are the `accent_mid` values from the card template (backoffice/profiles/card.html.erb) and
  # the same hexes as AppPalette.factionColors in the Flutter app — the colour a player recognises a
  # faction by. Not the backoffice's FACTION_PILL_STYLES, which this used to borrow: those are chip
  # backgrounds designed to sit behind dark text, so three of them are near-white pastels that all
  # but vanish as a standalone bar, and vivid alongside the other four.
  FACTION_COLORS = {
    "doctors"    => "#177282",
    "strigoi"    => "#2a3d6e",
    "gifted"     => "#b04510",
    "rashaar"    => "#1a5a40",
    "patricians" => "#5a1a7a",
    "vatican"    => "#8a6018",
    "guild"      => "#831822"
  }.freeze

  # The colour bar next to a faction on the printable-cards page. A faction the map has never heard
  # of still gets a bar, in the page's own border grey, rather than an invisible one.
  def faction_swatch_style(faction)
    "background:#{FACTION_COLORS.fetch(faction.to_s, 'var(--border)')};"
  end
end
