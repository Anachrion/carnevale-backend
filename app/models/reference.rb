class Reference < ApplicationRecord
  include HasFaction

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :faction, presence: true
  validates :cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
