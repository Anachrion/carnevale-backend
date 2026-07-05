FactoryBot.define do
  factory :spell, class: "Catalog::Spell" do
    sequence(:name) { |n| "Spell #{n}" }
    discipline { :blood_rites }
    cost { 1 }
    difficulty { 6 }
    cantrip { false }
  end
end
