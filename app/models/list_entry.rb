class ListEntry < ApplicationRecord
  belongs_to :list
  belongs_to :card_reference

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :list_id }
  validates :card_reference_id, uniqueness: { scope: :list_id }
end

# == Schema Information
#
# Table name: list_entries
#
#  id                :bigint           not null, primary key
#  position          :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  card_reference_id :bigint           not null
#  list_id           :bigint           not null
#
# Indexes
#
#  index_list_entries_on_card_reference_id              (card_reference_id)
#  index_list_entries_on_list_id                        (list_id)
#  index_list_entries_on_list_id_and_card_reference_id  (list_id,card_reference_id) UNIQUE
#  index_list_entries_on_list_id_and_position           (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (card_reference_id => card_references.id)
#  fk_rails_...  (list_id => lists.id)
#
