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
