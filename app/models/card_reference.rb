class CardReference < ApplicationRecord
  include HasFaction

  belongs_to :profile, optional: true

  has_many :list_entries, dependent: :destroy
  has_many :lists, through: :list_entries

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :faction, presence: true
  validates :cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

# == Schema Information
#
# Table name: card_references
#
#  id         :bigint           not null, primary key
#  cost       :integer          default(0), not null
#  faction    :string           not null
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint
#
# Indexes
#
#  index_card_references_on_identifier  (identifier) UNIQUE
#  index_card_references_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
