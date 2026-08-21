FactoryBot.define do
  factory :collection_item, class: "Collection::Item" do
    user
    profile
    owned { 1 }
    built { 0 }
    painted { 0 }
  end
end
