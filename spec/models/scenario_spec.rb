require 'rails_helper'

RSpec.describe Scenario, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: scenarios
#
#  id                :bigint           not null, primary key
#  agendas           :json             not null
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
