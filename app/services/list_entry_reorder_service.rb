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

class ListEntryReorderService
  def self.call(entry, new_position)
    new(entry, new_position).call
  end

  def initialize(entry, new_position)
    @entry = entry
    @list = entry.list
    @old_position = entry.position
    @new_position = new_position.clamp(1, @list.list_entries.count)
  end

  def call
    return if @old_position == @new_position

    # The whole shuffle must be atomic: parking the moved row at a temporary negative position and
    # the row-by-row shifts each temporarily violate the `(list_id, position)` UNIQUE index's final
    # invariant, so a failure partway through would leave gaps/dupes and make a retry hit
    # RecordNotUnique. Negative temp positions match ListSortingService's convention (they sit
    # outside the valid 1..N range, so they never collide with a real row mid-shuffle).
    Gang::Entry.transaction do
      @entry.update_columns(position: -1)

      if @new_position < @old_position
        @list.list_entries
             .where(position: @new_position..(@old_position - 1))
             .order(position: :desc)
             .each { |e| e.update_columns(position: e.position + 1) }
      else
        @list.list_entries
             .where(position: (@old_position + 1)..@new_position)
             .order(position: :asc)
             .each { |e| e.update_columns(position: e.position - 1) }
      end

      @entry.update_columns(position: @new_position)
    end
  end
end
