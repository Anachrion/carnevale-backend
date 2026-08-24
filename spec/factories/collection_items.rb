FactoryBot.define do
  factory :collection_item, class: "Collection::Item" do
    user
    profile
    owned { 1 }
    built { 0 }
    painted { 0 }
  end
end

# == Schema Information
#
# Table name: collection_items
#
#  id         :bigint           not null, primary key
#  built      :integer          default(0), not null
#  owned      :integer          default(0), not null
#  painted    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_collection_items_on_profile_id              (profile_id)
#  index_collection_items_on_user_id_and_profile_id  (user_id,profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (user_id => users.id)
#
