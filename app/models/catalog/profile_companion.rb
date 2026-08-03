# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
