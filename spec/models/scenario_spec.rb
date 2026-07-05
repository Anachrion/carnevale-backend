require 'rails_helper'

RSpec.describe Catalog::Scenario, type: :model do
  describe "#initial_agenda_count" do
    it "reads the leading number of the first agendas entry" do
      expect(build(:scenario, agendas: [ "5 agendas of doom" ]).initial_agenda_count).to eq(5)
    end

    it "falls back to the default when the first entry has no leading number" do
      expect(build(:scenario, agendas: [ "draw some agendas" ]).initial_agenda_count).to eq(3)
    end

    it "falls back to the default when there are no agendas" do
      expect(build(:scenario, agendas: []).initial_agenda_count).to eq(3)
    end
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
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
