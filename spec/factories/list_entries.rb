FactoryBot.define do
  factory :list_entry, class: "Gang::Entry" do
    association :list
    association :entry, factory: :reference
    sequence(:position)
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id         :bigint           not null, primary key
#  entry_type :string           not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :bigint           not null
#  list_id    :bigint           not null
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#
