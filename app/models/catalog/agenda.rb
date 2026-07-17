# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Catalog
  class Agenda < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :first_roll, presence: true
    validates :second_roll, presence: true, uniqueness: { scope: :first_roll }
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
