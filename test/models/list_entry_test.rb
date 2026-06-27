require "test_helper"
class ListEntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: list_entries
#
#  id                :bigint           not null, primary key
#  position          :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  card_reference_id :bigint           not null
#  list_id           :bigint           not null
#
# Indexes
#
#  index_list_entries_on_card_reference_id     (card_reference_id)
#  index_list_entries_on_list_id               (list_id)
#  index_list_entries_on_list_id_and_position  (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (card_reference_id => card_references.id)
#  fk_rails_...  (list_id => lists.id)
#
