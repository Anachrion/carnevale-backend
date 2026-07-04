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
#  id               :bigint           not null, primary key
#  faction          :string           not null
#  name             :string
#  owner_type       :string           not null
#  points           :integer          default(100), not null
#  selection_errors :json             not null
#  selection_valid  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  owner_id         :bigint           not null
#
# Indexes
#
#  index_lists_on_owner  (owner_type,owner_id)
#
