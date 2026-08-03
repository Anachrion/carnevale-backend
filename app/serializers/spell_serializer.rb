# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
