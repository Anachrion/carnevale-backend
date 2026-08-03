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
