FactoryBot.define do
  factory :agenda do
    sequence(:name) { |n| "Agenda #{n}" }
    description { "Kill an enemy character with the Leader keyword with a friendly character with the Leader keyword." }
    first_roll { "1-3" }
    sequence(:second_roll) { |n| n }
  end
end

# == Schema Information
#
# Table name: agendas
#
#  id          :bigint           not null, primary key
#  description :text             default(""), not null
#  first_roll  :string           not null
#  name        :string           not null
#  second_roll :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_agendas_on_first_roll_and_second_roll  (first_roll,second_roll) UNIQUE
#
