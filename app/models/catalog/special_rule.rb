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
  class SpecialRule < ApplicationRecord
    has_many :profile_special_rules, class_name: "Catalog::ProfileSpecialRule"
    has_many :profiles, through: :profile_special_rules

    # The spell columns are all optional: most rules are not spells at all. A handful of rules go
    # the other way — a unique spell granted to one model (Maria Fioritura's "Creative Creation")
    # is printed under the spell's name, so the rule's own name is deliberately blank. Hence a rule
    # must be named *somehow*, by one column or the other, rather than by :name alone.
    validates :name, presence: true, unless: -> { spell_name.present? }
    validates :spell_cost, :spell_difficulty,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

    # Shared, exactly like a weapon: see Catalog::Weapon#cards_affected.
    def cards_affected
      Catalog::CardReference.where(profile_id: profile_special_rules.select(:profile_id))
    end
  end
end

# == Schema Information
#
# Table name: special_rules
#
#  id                :bigint           not null, primary key
#  description       :text             default(""), not null
#  name              :string           not null
#  spell_cost        :integer
#  spell_description :text
#  spell_difficulty  :integer
#  spell_name        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
