# The lightweight list shape (no entries) used inside game payloads and the available-lists picker.
class ListSummarySerializer
  def initialize(list)
    @list = list
  end

  def as_json
    { id: @list.id, name: @list.name, faction: @list.faction, points: @list.points, total_cost: @list.total_cost }
  end
end
