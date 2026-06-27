class List < ApplicationRecord
  include HasFaction

  has_many :list_entries, dependent: :destroy
  has_many :card_references, through: :list_entries

  validates :name, presence: true
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :faction, presence: true

  validate :validate_roster

  private

  def validate_roster
    result = ListValidationService.call(self)
    result[:errors].each { |msg| errors.add(:base, msg) }
  end
end

# == Schema Information
#
# Table name: lists
#
#  id         :bigint           not null, primary key
#  faction    :string           not null
#  name       :string
#  points     :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
