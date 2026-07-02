class Agenda < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :first_roll, presence: true
  validates :second_roll, presence: true, uniqueness: { scope: :first_roll }
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
