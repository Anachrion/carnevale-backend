FactoryBot.define do
  factory :profile do
    sequence(:name) { |n| "Profile #{n}" }
    faction { :guild }
    ducats { 10 }
    keywords { [] }
    abilities { [] }
  end
end
