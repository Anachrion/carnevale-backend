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
