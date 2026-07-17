# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
