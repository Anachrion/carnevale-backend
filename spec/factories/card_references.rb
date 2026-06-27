FactoryBot.define do
  factory :card_reference, aliases: [:reference] do
    sequence(:name) { |n| "Reference #{n}" }
    sequence(:identifier) { |n| "guild-reference-#{n}" }
    association :profile

    transient do
      cost { nil }
    end

    after(:build) do |card_reference, evaluator|
      card_reference.profile.ducats = evaluator.cost if evaluator.cost
    end

    after(:create) do |card_reference, evaluator|
      if evaluator.cost
        card_reference.profile.update!(ducats: evaluator.cost)
        card_reference.association(:profile).reset
      end
    end
  end
end

# == Schema Information
#
# Table name: card_references
#
#  id         :bigint           not null, primary key
#  card_back  :string
#  card_front :string
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#
# Indexes
#
#  index_card_references_on_identifier  (identifier) UNIQUE
#  index_card_references_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
