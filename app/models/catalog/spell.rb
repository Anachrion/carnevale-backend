# SPDX-License-Identifier: AGPL-3.0-or-later

module Catalog
  class Spell < ApplicationRecord
    DISCIPLINES = %w[blood_rites divinity fateweaving runes_of_sovereignty wild_magic].freeze

    enum :discipline, DISCIPLINES.index_with(&:itself)

    # Edited in the backoffice (CARNEVALEB-86), so it has a history like weapons and rules.
    has_paper_trail

    # Gangs that chose this spell (player data) and profiles granted it. Both are foreign keys, so a
    # spell in use cannot be deleted.
    has_many :entry_spells, class_name: "Gang::EntrySpell"
    has_many :profile_granted_spells, class_name: "Catalog::ProfileGrantedSpell"

    scope :cantrips, -> { where(cantrip: true) }

    validates :name, presence: true, uniqueness: { scope: :discipline }
    validates :cost, :difficulty, presence: true
    validates :discipline, presence: true
    # A Mage knows its Discipline's one Cantrip (cantrip_for); a second would make that ambiguous.
    validates :cantrip, uniqueness: { scope: :discipline, message: "already exists for this discipline" }, if: :cantrip?

    def in_use?
      entry_spells.exists? || profile_granted_spells.exists?
    end

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
#  index_spells_on_name_and_discipline      (name,discipline) UNIQUE
#  index_spells_one_cantrip_per_discipline  (discipline) UNIQUE WHERE cantrip
#
