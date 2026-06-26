require "test_helper"
class ReferenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: references
#
#  id         :bigint           not null, primary key
#  cost       :integer          default(0), not null
#  faction    :string           not null
#  identifier :string           not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_references_on_identifier  (identifier) UNIQUE
#
