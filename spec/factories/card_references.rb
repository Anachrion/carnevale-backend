FactoryBot.define do
  factory :card_reference do
    sequence(:name) { |n| "Reference #{n}" }
    sequence(:identifier) { |n| "guild-reference-#{n}" }
    association :profile
  end
end

# == Schema Information
#
# Table name: card_references
#
#  id                :bigint           not null, primary key
#  card_back         :string
#  card_front        :string
#  identifier        :string           not null
#  illustration_path :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  profile_id        :bigint           not null
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
