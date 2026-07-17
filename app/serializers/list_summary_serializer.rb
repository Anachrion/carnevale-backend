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
