# == Schema Information
#
# Table name: references
#
#  id         :bigint           not null, primary key
#  cost       :integer          default(0), not null
#  faction    :string           not null
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_references_on_identifier  (identifier) UNIQUE
#
FactoryBot.define do
  factory :reference do
    sequence(:name) { |n| "Reference #{n}" }
    sequence(:identifier) { |n| "guild-reference-#{n}" }
    faction { :guild }
    cost { 10 }
  end
end
