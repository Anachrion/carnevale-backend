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
  # Presentation for the catalog *around* the cards — the browse table, the publish page.
  #
  # Deliberately not in ProfilesHelper: that file is one of the inputs to
  # Catalog::CardReference.template_digest, so editing it marks every rendered card as stale.
  # Helpers that only dress up the backoffice's own screens have no business doing that.
  module CatalogHelper
    # How the editor lays the eleven stats out: the five the card prints as a row, under the
    # headings it prints them with, then the cost and the point pools. A form that reads like the
    # card it describes beats an alphabet of one-value-per-line fields.
    STAT_ROWS = {
      "Stats" => {
        movement: "MOV", dexterity: "DEX", attack: "ATT", protection: "PRO", mind: "MIND"
      },
      "Cost & points" => {
        ducats: "Ducats", action_points: "AP", will_points: "Will",
        command_points: "Cmd", life_points: "Life", size: "Size"
      }
    }.freeze

    # The rows above, plus anything in Catalog::Profile::STATS they forgot: a stat added to the
    # model still gets a field rather than quietly going missing from the only form that edits it.
    def profile_stat_rows
      unplaced = Catalog::Profile::STATS - STAT_ROWS.values.flat_map(&:keys)
      return STAT_ROWS if unplaced.empty?

      STAT_ROWS.merge("Other" => unplaced.index_with { |stat| stat.to_s.humanize })
    end

    # The internal_version the app sees for this profile's cards. A profile can own more than one
    # card (an A/B pair), and they drift apart, so show each distinct version it currently carries.
    def card_versions(profile)
      versions = profile.card_references.map(&:internal_version).uniq.sort
      return tag.span("—", style: "color:#9ca3af;") if versions.empty?

      tag.span("v#{versions.join(", v")}",
        title: "internal_version advertised to the app",
        style: "font-variant-numeric:tabular-nums;color:#374151;")
    end

    # The ability names allowed in a given category — abilities are held to the Catalog::Ability
    # glossary, so a form has to say what it will accept. Shown under the abilities textareas.
    def ability_glossary_hint(category)
      names = Catalog::Ability.where(category: category).order(:name).pluck(:name)
      tag.div(style: "color:#6b7280;font-size:13px;margin-top:6px;") do
        safe_join([
          tag.span("Must be one of these #{category} abilities (a “(X)” rating may follow): "),
          tag.span(names.join(", "), style: "color:#374151;")
        ])
      end
    end
  end
end
