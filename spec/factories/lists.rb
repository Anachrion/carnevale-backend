FactoryBot.define do
  factory :list, class: "Gang::List" do
    association :owner, factory: :user
    sequence(:name) { |n| "Gang #{n}" }
    faction { :guild }
    points { 100 }
  end
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
#  source_list_id   :bigint
#
# Indexes
#
#  index_lists_on_owner           (owner_type,owner_id)
#  index_lists_on_source_list_id  (source_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_list_id => lists.id) ON DELETE => nullify
#
