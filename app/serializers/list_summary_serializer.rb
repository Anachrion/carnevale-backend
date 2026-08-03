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

# The lightweight list shape (no entries) used inside game payloads and the available-lists picker.
class ListSummarySerializer
  # `total_cost` may be supplied pre-computed (batched across many lists — see Gang::List
  # .total_costs_for) to avoid the two aggregate queries `@list.total_cost` runs; falls back to
  # computing it for a lone list (e.g. the available-lists picker).
  def initialize(list, total_cost: nil)
    @list = list
    @total_cost = total_cost
  end

  def as_json
    { id: @list.id, source_list_id: @list.source_list_id, name: @list.name, faction: @list.faction, points: @list.points, total_cost: @total_cost || @list.total_cost }
  end
end
