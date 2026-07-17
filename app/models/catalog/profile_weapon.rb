# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Catalog
  class ProfileWeapon < ApplicationRecord
    belongs_to :profile, class_name: "Catalog::Profile"
    belongs_to :weapon, class_name: "Catalog::Weapon"
  end
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
