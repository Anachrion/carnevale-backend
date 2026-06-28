class ListEntry < ApplicationRecord
  belongs_to :list
  belongs_to :entry, polymorphic: true

  delegate :cost, to: :entry

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :list_id }

  validate :validate_list_roster, on: :create

  private

  def validate_list_roster
    result = ListValidationService.call(list, adding: entry)
    result[:errors].each { |msg| errors.add(:base, msg) }
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id         :bigint           not null, primary key
#  entry_type :string           not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :bigint           not null
#  list_id    :bigint           not null
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#
