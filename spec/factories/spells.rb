FactoryBot.define do
  factory :spell, class: "Catalog::Spell" do
    sequence(:name) { |n| "Spell #{n}" }
    discipline { :blood_rites }
    cost { 1 }
    difficulty { 6 }
    cantrip { false }
  end
end

# == Schema Information
#
# Table name: spells
#
#  id          :bigint           not null, primary key
#  cantrip     :boolean          default(FALSE), not null
#  cost        :integer          not null
#  description :text             default(""), not null
#  difficulty  :integer          not null
#  discipline  :string           not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
