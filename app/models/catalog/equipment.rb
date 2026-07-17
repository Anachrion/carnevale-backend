module Catalog
  class Equipment < ApplicationRecord
    # Embedded in the /profiles and /lists payloads with a non-nullable contract, and cost feeds
    # list totals (a nil would be coerced to 0 and silently make the item free) — so keep the data
    # complete and sane (B-27).
    validates :name, presence: true
    validates :cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
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
