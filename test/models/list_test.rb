require "test_helper"
class ListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: lists
#
#  id         :bigint           not null, primary key
#  faction    :string           not null
#  name       :string
#  points     :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
