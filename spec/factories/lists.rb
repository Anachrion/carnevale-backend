FactoryBot.define do
  factory :list do
    sequence(:name) { |n| "Gang #{n}" }
    faction { :guild }
    points { 100 }
  end
end

# == Schema Information
#
# Table name: lists
#
#  id         :bigint           not null, primary key
#  faction    :string           not null
#  name       :string
#  points     :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
