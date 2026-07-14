FactoryBot.define do
  factory :profile, class: "Catalog::Profile" do
    sequence(:name) { |n| "Profile #{n}" }
    faction { :guild }
    ducats { 10 }
    keywords { [] }
    abilities { [] }

    # A profile's abilities are held to the Catalog::Ability glossary (character category), so any
    # ability a spec asks for must exist there. Provision it here rather than making every spec
    # that builds a profile with abilities seed the glossary by hand.
    before(:create) do |profile|
      profile.abilities.each do |entry|
        Catalog::Ability.find_or_create_by!(category: "character", name: Catalog::Ability.base_name(entry))
      end
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id             :bigint           not null, primary key
#  abilities      :json             not null
#  action_points  :integer          default(0), not null
#  attack         :integer          default(0), not null
#  command_points :integer          default(0), not null
#  dexterity      :integer          default(0), not null
#  ducats         :integer          default(0), not null
#  faction        :string           default(NULL), not null
#  keywords       :json             not null
#  life_points    :integer          default(0), not null
#  mind           :integer          default(0), not null
#  movement       :integer          default(0), not null
#  name           :string           default(""), not null
#  protection     :integer          default(0), not null
#  size           :integer          default(0), not null
#  version        :string           default("2.2.0"), not null
#  will_points    :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
