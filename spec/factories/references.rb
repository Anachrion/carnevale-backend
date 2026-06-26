FactoryBot.define do
  factory :reference do
    sequence(:name) { |n| "Reference #{n}" }
    sequence(:identifier) { |n| "guild-reference-#{n}" }
    faction { :guild }
    cost { 10 }
  end
end
