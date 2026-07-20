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
  # A model a profile automatically brings into a gang (CARNEVALEB-23). `base_quantity` copies of
  # `companion_profile` come for free; `upgraded_quantity` once the parent's paid upgrade is bought
  # (see Catalog::Profile#companion_upgrade_ducats).
  class ProfileCompanion < ApplicationRecord
    belongs_to :profile, class_name: "Catalog::Profile"
    belongs_to :companion_profile, class_name: "Catalog::Profile"

    validates :base_quantity, :upgraded_quantity,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end

# == Schema Information
#
# Table name: profile_companions
#
#  id                   :bigint           not null, primary key
#  base_quantity        :integer          default(1), not null
#  upgraded_quantity    :integer          default(1), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  companion_profile_id :bigint           not null
#  profile_id           :bigint           not null
#
# Indexes
#
#  index_profile_companions_on_companion_profile_id            (companion_profile_id)
#  index_profile_companions_on_profile_and_companion          (profile_id,companion_profile_id) UNIQUE
#  index_profile_companions_on_profile_id                      (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (companion_profile_id => profiles.id)
#  fk_rails_...  (profile_id => profiles.id)
#
