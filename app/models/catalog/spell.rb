module Catalog
  class Spell < ApplicationRecord
    DISCIPLINES = %w[blood_rites divinity fateweaving runes_of_sovereignty wild_magic].freeze

    enum :discipline, DISCIPLINES.index_with(&:itself)

    validates :name, presence: true, uniqueness: { scope: :discipline }
    validates :cost, :difficulty, presence: true
    validates :discipline, presence: true
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
