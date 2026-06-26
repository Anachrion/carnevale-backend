FactoryBot.define do
  factory :list do
    sequence(:name) { |n| "Gang #{n}" }
    faction { :guild }
    points { 100 }
  end
end
