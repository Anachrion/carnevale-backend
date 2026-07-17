module Catalog
  class Scenario < ApplicationRecord
    # The agenda special rules a scenario can carry (rulebook p.36). Stored structurally in the
    # `agenda_rules` JSON column rather than sniffed from the free-text `agendas` array (B-P2-11),
    # so the game logic (Secret visibility, Cycle auto-draw, …) reads a single sturdy source.
    AGENDA_RULES = %w[cycle secondary double secret total].freeze

    validates :name, presence: true, uniqueness: true
    validates :agenda_count, numericality: { only_integer: true, greater_than: 0 }
    validate :agenda_rules_subset

    # Predicates for each rule, used by the encounter subsystem and serializers. Endless-method
    # form keeps them a readable one-liner apiece rather than a metaprogrammed loop.
    def cycle_agendas? = agenda_rules.include?("cycle")
    def secondary_agendas? = agenda_rules.include?("secondary")
    def double_agendas? = agenda_rules.include?("double")
    def secret_agendas? = agenda_rules.include?("secret")
    def total_agendas? = agenda_rules.include?("total")

    private

    def agenda_rules_subset
      return if agenda_rules.is_a?(Array) && (agenda_rules - AGENDA_RULES).empty?

      errors.add(:agenda_rules, "must be a subset of #{AGENDA_RULES.join(', ')}")
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
# Indexes
#
#  index_scenarios_on_name  (name) UNIQUE
#
