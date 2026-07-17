module Gang
  class EntryPoolDiscipline < ApplicationRecord
    include RefreshesListSelectionValidity

    self.table_name = "entry_pool_disciplines"

    belongs_to :list_entry, class_name: "Gang::Entry"
    belongs_to :pool, class_name: "Catalog::ProfileSpellPool"

    validates :discipline, inclusion: { in: Catalog::Spell::DISCIPLINES }

    private

    def selection_validity_list
      list_entry&.list
    end
  end
end

# == Schema Information
#
# Table name: entry_pool_disciplines
#
#  id            :bigint           not null, primary key
#  discipline    :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_entry_id :bigint           not null
#  pool_id       :bigint           not null
#
# Indexes
#
#  index_entry_pool_disciplines_on_list_entry_id  (list_entry_id)
#  index_entry_pool_disciplines_on_pool_id        (pool_id)
#  index_entry_pool_disciplines_uniqueness        (list_entry_id,pool_id,discipline) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#  fk_rails_...  (pool_id => profile_spell_pools.id) ON DELETE => cascade
#
