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
