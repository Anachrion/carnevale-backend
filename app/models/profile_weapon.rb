class ProfileWeapon < ApplicationRecord
  belongs_to :profile
  belongs_to :weapon
end

# == Schema Information
#
# Table name: profile_weapons
#
#  id         :bigint           not null, primary key
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#  weapon_id  :bigint           not null
#
# Indexes
#
#  index_profile_weapons_on_profile_id  (profile_id)
#  index_profile_weapons_on_weapon_id   (weapon_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (weapon_id => weapons.id)
#
