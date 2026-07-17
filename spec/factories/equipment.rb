FactoryBot.define do
  factory :equipment, class: "Catalog::Equipment" do
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
#  cost        :integer          not null
#  description :text             default(""), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
