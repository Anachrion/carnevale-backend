# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
      agenda_rules: s.agenda_rules,
      agenda_count: s.agenda_count,
      special_rules: s.special_rules,
      duration: s.duration,
      turns: s.turns,
      deployment_zones: s.deployment_zones,
      illustration: s.illustration
    }
  end
end
