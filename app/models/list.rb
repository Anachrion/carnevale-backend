class List < ApplicationRecord
  include HasFaction

  validates :name, presence: true
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :faction, presence: true
end
