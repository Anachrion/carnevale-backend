class Weapon < ApplicationRecord
  has_many :profile_weapons
  has_many :profiles, through: :profile_weapons
end

# == Schema Information
#
# Table name: weapons
#
#  id          :bigint           not null, primary key
#  abilities   :json             not null
#  damage      :integer          default(0), not null
#  evasion     :integer          default(0), not null
#  name        :string           not null
#  penetration :integer          default(0), not null
#  range       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
