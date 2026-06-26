FactoryBot.define do
  factory :list_entry do
    association :list
    association :reference
    sequence(:position)
  end
end
