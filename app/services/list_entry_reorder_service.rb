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

class ListEntryReorderService
  def self.call(entry, new_position)
    new(entry, new_position).call
  end

  def initialize(entry, new_position)
    @entry = entry
    @list = entry.list
    @new_position = new_position
  end

  # Moves the entry to `new_position` (1-based) and renumbers the whole list to a contiguous 1..N.
  # Works off the ordered *list* by index rather than by position arithmetic, so it's correct even
  # when positions have gaps — which they do now that adds append at max+1 and removes leave holes
  # (the old renumber-on-every-add is gone). Renumbering also heals those gaps, so the stored order
  # always matches the client's index-based view and a synced reorder never visibly jumps back.
  def call
    entries = @list.list_entries.order(:position).to_a
    current = entries.index { |e| e.id == @entry.id }
    return if current.nil?

    target = (@new_position - 1).clamp(0, entries.size - 1)
    return if current == target

    entries.insert(target, entries.delete_at(current))

    # Two passes (temporary negative positions, then the final 1..N) sidestep the
    # `(list_id, position)` UNIQUE index mid-shuffle; the transaction makes the whole renumber atomic
    # so a failure can't strand the list with negative/duplicate positions.
    Gang::Entry.transaction do
      entries.each_with_index { |e, i| e.update_columns(position: -(i + 1)) }
      entries.each_with_index { |e, i| e.update_columns(position: i + 1) }
    end
  end
end
