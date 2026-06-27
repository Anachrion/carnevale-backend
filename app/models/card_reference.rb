class CardReference < ApplicationRecord
  belongs_to :profile

  has_many :list_entries, dependent: :destroy
  has_many :lists, through: :list_entries

  delegate :faction, to: :profile, allow_nil: true

  def cost
    profile&.ducats
  end

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: card_references
#
#  id         :bigint           not null, primary key
#  card_back  :string
#  card_front :string
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
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
