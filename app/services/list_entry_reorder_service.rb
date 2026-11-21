# SPDX-License-Identifier: AGPL-3.0-or-later

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
