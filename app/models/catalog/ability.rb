# SPDX-License-Identifier: AGPL-3.0-or-later

module Catalog
  # A generic glossary rule from the rulebook's Special Rules section (p44-48): either a
  # Character Ability or a Weapon Ability. Unlike a Catalog::SpecialRule (a named, model-specific
  # rule), these are the shared rules referenced by name from Profile#abilities and Weapon#abilities.
  #
  # The stored name is the base name without the "(X)" rating (e.g. "Acrobatic", not "Acrobatic (2)");
  # callers strip the rating before looking a rule up.
  class Ability < ApplicationRecord
    CATEGORIES = %w[character weapon].freeze

    validates :category, inclusion: { in: CATEGORIES }
    validates :name, presence: true, uniqueness: { scope: :category }

    scope :character, -> { where(category: "character") }
    scope :weapon, -> { where(category: "weapon") }

    # The trailing "(X)" rating an entry may carry — "(2)", "(-2)", "(X)". The glossary stores the
    # base name without it, so it is stripped before a lookup.
    RATING = /\s*\([^)]*\)\s*\z/

    # "Acrobatic (2)" => "Acrobatic"; "Water Creature" => "Water Creature".
    def self.base_name(entry)
      entry.to_s.sub(RATING, "").strip
    end

    # The base names known in a category, as a Set for membership tests.
    def self.known_names(category)
      where(category: category).pluck(:name).to_set
    end

    # Matches any glossary ability named in rule prose, plus the "(X)" rating that may trail it, so
    # the card can bold the whole "Acrobatic (2)". Built from the table rather than a hand-kept list
    # so an ability added to the catalog starts bolding without a matching code change — the two
    # drifted once already, and "Aerobatic" sat in the list unmatched for as long as it took someone
    # to notice a keyword printing plain.
    #
    # Longest name first: an alternation stops at its first hit, so a shorter name that prefixes a
    # longer one ("Expert" against "Expert Offence") would otherwise bold only its own half.
    def self.keyword_pattern
      names = pluck(:name).uniq.reject(&:blank?).sort_by { |name| [ -name.length, name ] }
      # An empty alternation matches the empty string everywhere; match nothing instead.
      return /(?!)/ if names.empty?

      /\b(#{names.map { |name| Regexp.escape(name) }.join("|")})(?!\w)(\s*\([^)]+\))?/
    end
  end
end

# == Schema Information
#
# Table name: abilities
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :text             default(""), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_abilities_on_category_and_name  (category,name) UNIQUE
#
