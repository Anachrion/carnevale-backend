module Backoffice
  # Presentation for the catalog *around* the cards — the browse table, the render queue.
  #
  # Deliberately not in ProfilesHelper: that file is one of the inputs to
  # Catalog::CardReference.template_digest, so editing it marks every rendered card as stale.
  # Helpers that only dress up the backoffice's own screens have no business doing that.
  module CatalogHelper
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
