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

# Serializers render domain records to the plain Hashes the API returns, keeping presentation out
# of the models and controllers (one convention: `Serializer.new(record, **context).as_json`, B-P2-8).
class SpellSerializer
  def initialize(spell)
    @spell = spell
  end

  def as_json
    {
      id: @spell.id,
      name: @spell.name,
      discipline: @spell.discipline,
      cost: @spell.cost,
      difficulty: @spell.difficulty,
      cantrip: @spell.cantrip,
      description: @spell.description
    }
  end
end
