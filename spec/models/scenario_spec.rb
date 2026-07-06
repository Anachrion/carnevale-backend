require 'rails_helper'

RSpec.describe Catalog::Scenario, type: :model do
  describe "agenda rule predicates" do
    it "is true for each rule present in agenda_rules and false otherwise" do
      scenario = build(:scenario, agenda_rules: [ "secret", "cycle" ])

      expect(scenario.secret_agendas?).to be true
      expect(scenario.cycle_agendas?).to be true
      expect(scenario.double_agendas?).to be false
      expect(scenario.secondary_agendas?).to be false
      expect(scenario.total_agendas?).to be false
    end

    it "is false for every rule when agenda_rules is empty" do
      scenario = build(:scenario, agenda_rules: [])

      expect(Catalog::Scenario::AGENDA_RULES.none? { |r| scenario.public_send("#{r}_agendas?") }).to be true
    end
  end

  describe "validations" do
    it "accepts a subset of the known agenda rules" do
      expect(build(:scenario, agenda_rules: [ "secret", "cycle", "double" ])).to be_valid
    end

    it "rejects an unknown agenda rule" do
      scenario = build(:scenario, agenda_rules: [ "bogus" ])

      expect(scenario).not_to be_valid
      expect(scenario.errors[:agenda_rules]).to be_present
    end

    it "requires a positive agenda_count" do
      expect(build(:scenario, agenda_count: 0)).not_to be_valid
    end
  end
end

# == Schema Information
#
# Table name: scenarios
#
#  id                :bigint           not null, primary key
#  agenda_count      :integer          default(3), not null
#  agenda_rules      :json             not null
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
