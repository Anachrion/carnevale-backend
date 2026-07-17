module Catalog
  class ProfileSpellPoolDiscipline < ApplicationRecord
    self.table_name = "profile_spell_pool_disciplines"

    belongs_to :pool, class_name: "Catalog::ProfileSpellPool"

    validates :discipline, inclusion: { in: Catalog::Spell::DISCIPLINES }
  end
end

# == Schema Information
#
# Table name: profile_spell_pool_disciplines
#
#  id         :bigint           not null, primary key
#  discipline :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pool_id    :bigint           not null
#
# Indexes
#
#  index_pool_disciplines_on_pool_and_discipline    (pool_id,discipline) UNIQUE
#  index_profile_spell_pool_disciplines_on_pool_id  (pool_id)
#
# Foreign Keys
#
#  fk_rails_...  (pool_id => profile_spell_pools.id)
#
