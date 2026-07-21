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
#  id                    :bigint           not null, primary key
#  entry_type            :string           not null
#  position              :integer          not null
#  request_key           :string
#  summoned              :boolean          default(FALSE), not null
#  upgrade_selected      :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  companion_of_entry_id :bigint
#  entry_id              :bigint           not null
#  list_id               :bigint           not null
#  mentored_by_entry_id  :bigint
#
# Indexes
#
#  index_list_entries_on_companion_of_entry_id    (companion_of_entry_id)
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#  index_list_entries_on_list_id_and_request_key  (list_id,request_key) UNIQUE WHERE (request_key IS NOT NULL)
#  index_list_entries_on_mentored_by_entry_id     (mentored_by_entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (companion_of_entry_id => list_entries.id) ON DELETE => cascade
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (mentored_by_entry_id => list_entries.id) ON DELETE => nullify
#
