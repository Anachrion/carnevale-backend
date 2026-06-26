class Reference < ApplicationRecord
  include HasFaction

  has_many :list_entries, dependent: :destroy
  has_many :lists, through: :list_entries

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :faction, presence: true
  validates :cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

# == Schema Information
#
# Table name: references
#
#  id         :bigint           not null, primary key
#  cost       :integer          default(0), not null
#  faction    :string           not null
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_references_on_identifier  (identifier) UNIQUE
#
