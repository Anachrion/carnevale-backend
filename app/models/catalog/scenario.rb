module Catalog
  class Scenario < ApplicationRecord
    validates :name, presence: true, uniqueness: true

    def as_json_for_game
      {
        id: id,
        name: name,
        ducats: ducats,
        asymmetric: asymmetric,
        setup: setup,
        primary_objective: primary_objective,
        agendas: agendas,
        special_rules: special_rules,
        duration: duration,
        turns: turns,
        deployment_zones: deployment_zones,
        illustration: illustration
      }
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
#  turns             :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
