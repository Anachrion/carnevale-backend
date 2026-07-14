FactoryBot.define do
  factory :illustration, class: "Catalog::Illustration" do
    association :profile
    sequence(:path) { |n| "p#{format('%02d', n)}.png" }
    number { 1 }
  end
end
