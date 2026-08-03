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
  class Spell < ApplicationRecord
    DISCIPLINES = %w[blood_rites divinity fateweaving runes_of_sovereignty wild_magic].freeze

    enum :discipline, DISCIPLINES.index_with(&:itself)

    scope :cantrips, -> { where(cantrip: true) }

    validates :name, presence: true, uniqueness: { scope: :discipline }
    validates :cost, :difficulty, presence: true
    validates :discipline, presence: true

    # The free Cantrip a Mage of the given Discipline always knows (rulebook p24), or nil.
    def self.cantrip_for(discipline)
      cantrips.find_by(discipline: discipline)
    end
  end
end

# == Schema Information
#
# Table name: spells
#
#  id          :bigint           not null, primary key
#  cantrip     :boolean          default(FALSE), not null
#  cost        :integer          not null
#  description :text             default(""), not null
#  difficulty  :integer          not null
#  discipline  :string           not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_spells_on_name_and_discipline  (name,discipline) UNIQUE
#
