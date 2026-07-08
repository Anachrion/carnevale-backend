FactoryBot.define do
  factory :ability, class: "Catalog::Ability" do
    sequence(:name) { |n| "Ability #{n}" }
    category { "character" }
    description { "Does something notable." }
  end
end

# == Schema Information
#
# Table name: abilities
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :text             default(""), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
