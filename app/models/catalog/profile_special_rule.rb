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
