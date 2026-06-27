class SpecialRule < ApplicationRecord
  has_many :profile_special_rules
  has_many :profiles, through: :profile_special_rules
end

# == Schema Information
#
# Table name: special_rules
#
#  id                :bigint           not null, primary key
#  description       :text             default(""), not null
#  name              :string           not null
#  spell_cost        :integer
#  spell_description :text
#  spell_difficulty  :integer
#  spell_name        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
