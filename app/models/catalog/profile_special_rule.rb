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
  class ProfileSpecialRule < ApplicationRecord
    belongs_to :profile, class_name: "Catalog::Profile"
    belongs_to :special_rule, class_name: "Catalog::SpecialRule"
  end
end

# == Schema Information
#
# Table name: profile_special_rules
#
#  id              :bigint           not null, primary key
#  position        :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  profile_id      :bigint           not null
#  special_rule_id :bigint           not null
#
# Indexes
#
#  index_profile_special_rules_on_profile_id       (profile_id)
#  index_profile_special_rules_on_special_rule_id  (special_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (special_rule_id => special_rules.id)
#
