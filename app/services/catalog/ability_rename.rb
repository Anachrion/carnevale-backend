# SPDX-License-Identifier: AGPL-3.0-or-later

module Catalog
  # Renames a glossary ability and every card that lists it (CARNEVALEB-86).
  #
  # Profiles and weapons name their abilities as strings ("Acrobatic (2)"), checked against the
  # glossary on save. Renaming only the glossary entry would leave every carrying card naming an
  # ability that no longer exists, failing validation the next time anyone saves it. So the cards
  # are rewritten in the same transaction, keeping each one's rating.
  #
  # Weapons are versioned by paper_trail on their own; each profile changed gets a card version
  # (Catalog::History), so the rename shows up in the history of every card it touched.
  class AbilityRename
    def self.call(ability, new_name, attributes = {}) = new(ability, new_name, attributes).call

    def initialize(ability, new_name, attributes)
      @ability = ability
      @old_name = ability.name
      @new_name = new_name.to_s.strip
      @attributes = attributes
    end

    # Returns the records rewritten (profiles or weapons). Raises ActiveRecord::RecordInvalid if
    # the ability or a card fails to save; nothing is written then.
    def call
      ActiveRecord::Base.transaction do
        carriers = renaming? ? @ability.carriers : []
        @ability.update!(@attributes.merge(name: @new_name))
        carriers.each { |record| rewrite(record) }
        carriers
      end
    end

    private

    def renaming?
      @new_name.present? && @new_name != @old_name
    end

    def rewrite(record)
      before = Catalog::CardSnapshot.capture(record) if record.is_a?(Catalog::Profile)
      record.update!(abilities: record.abilities.map { |entry| renamed(entry) })
      Catalog::History.record!(record, event: "update", before: before) if before
    end

    # "Acrobatic (2)" => "Acrobatics (2)"; entries naming another ability are left alone.
    def renamed(entry)
      return entry unless Catalog::Ability.base_name(entry) == @old_name

      rating = entry.to_s[Catalog::Ability::RATING].to_s
      "#{@new_name}#{rating.rstrip}"
    end
  end
end
