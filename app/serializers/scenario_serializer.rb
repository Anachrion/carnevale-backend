class ScenarioSerializer
  def initialize(scenario)
    @scenario = scenario
  end

  def as_json
    s = @scenario
    {
      id: s.id,
      name: s.name,
      ducats: s.ducats,
      asymmetric: s.asymmetric,
      setup: s.setup,
      primary_objective: s.primary_objective,
      agendas: s.agendas,
      special_rules: s.special_rules,
      duration: s.duration,
      turns: s.turns,
      deployment_zones: s.deployment_zones,
      illustration: s.illustration
    }
  end
end
