# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
#  index_agendas_on_name                        (name) UNIQUE
#
