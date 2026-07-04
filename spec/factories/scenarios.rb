FactoryBot.define do
  factory :scenario, class: "Catalog::Scenario" do
    sequence(:name) { |n| "Scenario #{n}" }
    ducats { 150 }
    setup { "3'x3' board." }
    primary_objective { "Each friendly character on the board at the end of the game scores 1 Victory Point." }
    agendas { ["3 scoring 1 Victory Point each."] }
    special_rules { [] }
    duration { "5 rounds." }
    turns { 5 }
    deployment_zones { ["Up to 8\" away from opposite board edges."] }
  end
end

# == Schema Information
#
# Table name: scenarios
#
#  id                :bigint           not null, primary key
#  agendas           :json             not null
#  asymmetric        :boolean          default(FALSE), not null
#  deployment_zones  :json             not null
#  ducats            :integer          default(0), not null
#  duration          :string           default(""), not null
#  illustration      :string
#  name              :string           not null
#  primary_objective :text             default(""), not null
#  setup             :text             default(""), not null
#  special_rules     :json             not null
#  turns             :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
