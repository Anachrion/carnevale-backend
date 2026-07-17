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
