module Catalog
  class Scenario < ApplicationRecord
    DEFAULT_AGENDA_DRAW = 3

    validates :name, presence: true, uniqueness: true

    # Initial agenda hand size, read from the leading number of the first `agendas` entry
    # (e.g. "3 agendas ..."), falling back to DEFAULT_AGENDA_DRAW when it's absent or unparseable.
    # Centralised here so the fragile format assumption lives in one named, tested place rather than
    # inline in Encounter::Game (B-P2-11).
    def initial_agenda_count
      parsed = agendas.first.to_s[/\A(\d+)/, 1].to_i
      parsed.zero? ? DEFAULT_AGENDA_DRAW : parsed
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
