class Illustration < ApplicationRecord
  belongs_to :profile

  validates :path, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :number, uniqueness: { scope: :profile_id }
end

# == Schema Information
#
# Table name: illustrations
#
#  id         :bigint           not null, primary key
#  flipped    :boolean          default(FALSE), not null
#  number     :integer          default(1), not null
#  offset_x   :integer          default(0), not null
#  offset_y   :integer          default(0), not null
#  path       :string           not null
#  zoom       :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#
# Indexes
#
#  index_illustrations_on_profile_id             (profile_id)
#  index_illustrations_on_profile_id_and_number  (profile_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
