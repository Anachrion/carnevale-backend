class ListEntry < ApplicationRecord
  belongs_to :list
  belongs_to :reference

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :list_id }
  validates :reference_id, uniqueness: { scope: :list_id }
end
