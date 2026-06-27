class Profile < ApplicationRecord
  include HasFaction

  has_many :card_references

  has_many :illustrations, -> { order(:number) }

  has_many :profile_weapons, -> { order(:position) }
  has_many :weapons, through: :profile_weapons

  has_many :profile_special_rules, -> { order(:position) }
  has_many :special_rules, through: :profile_special_rules
end

# == Schema Information
#
# Table name: profiles
#
#  id             :bigint           not null, primary key
#  abilities      :json             not null
#  action_points  :integer          default(0), not null
#  attack         :integer          default(0), not null
#  command_points :integer          default(0), not null
#  dexterity      :integer          default(0), not null
#  ducats         :integer          default(0), not null
#  faction        :string           default(NULL), not null
#  keywords       :json             not null
#  life_points    :integer          default(0), not null
#  mind           :integer          default(0), not null
#  movement       :integer          default(0), not null
#  name           :string           default(""), not null
#  protection     :integer          default(0), not null
#  size           :integer          default(0), not null
#  version        :string           default("2.2.0"), not null
#  will_points    :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
