# == Schema Information
#
# Table name: list_entries
#
#  id           :bigint           not null, primary key
#  position     :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  list_id      :bigint           not null
#  reference_id :bigint           not null
#
# Indexes
#
#  index_list_entries_on_list_id                   (list_id)
#  index_list_entries_on_list_id_and_position      (list_id,position) UNIQUE
#  index_list_entries_on_list_id_and_reference_id  (list_id,reference_id) UNIQUE
#  index_list_entries_on_reference_id              (reference_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (reference_id => references.id)
#
class ListEntry < ApplicationRecord
  belongs_to :list
  belongs_to :reference

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :list_id }
  validates :reference_id, uniqueness: { scope: :list_id }
end
