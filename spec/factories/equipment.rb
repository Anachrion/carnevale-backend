FactoryBot.define do
  factory :equipment do
    name { "MyString" }
    description { "MyText" }
    cost { 1 }
  end
end

# == Schema Information
#
# Table name: equipment
#
#  id          :bigint           not null, primary key
#  cost        :integer
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
