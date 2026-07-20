FactoryBot.define do
  factory :profile_companion, class: "Catalog::ProfileCompanion" do
    association :profile
    association :companion_profile, factory: :profile
    base_quantity { 1 }
    upgraded_quantity { 2 }
  end
end

# == Schema Information
#
# Table name: profile_companions
#
#  id                   :bigint           not null, primary key
#  base_quantity        :integer          default(1), not null
#  upgraded_quantity    :integer          default(1), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  companion_profile_id :bigint           not null
#  profile_id           :bigint           not null
#
