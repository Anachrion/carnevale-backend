class List < ApplicationRecord
  include HasFaction

  has_many :list_entries, dependent: :destroy
  has_many :references, through: :list_entries

  validates :name, presence: true
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :faction, presence: true
end
