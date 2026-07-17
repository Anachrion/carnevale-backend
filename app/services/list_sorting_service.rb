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

class ListSortingService
  ROLE_RANK = { "Leader" => 0, "Hero" => 1 }.freeze

  def self.call(list)
    new(list).call
  end

  def initialize(list)
    @list = list
  end

  def call
    entries = @list.list_entries.includes(:entry).to_a
    # `entry` is polymorphic and only card references have a profile; preload it on those in one
    # query so role_rank and cost (both read the profile) don't N+1 per entry (B-P2-1).
    card_references = entries.map(&:entry).grep(Catalog::CardReference)
    if card_references.any?
      ActiveRecord::Associations::Preloader.new(records: card_references, associations: :profile).call
    end

    sorted = entries.sort_by { |e| [role_rank(e), e.cost.to_i] }

    # Two passes (temporary negative positions, then final positive ones) sidestep the
    # `(list_id, position)` UNIQUE index mid-shuffle; wrap both in a transaction so a failure can't
    # leave the list stranded with negative/duplicate positions.
    Gang::Entry.transaction do
      sorted.each_with_index { |entry, index| entry.update_columns(position: -(index + 1)) }
      sorted.each_with_index { |entry, index| entry.update_columns(position: index + 1) }
    end
  end

  private

  def role_rank(entry)
    return 3 unless entry.entry.is_a?(Catalog::CardReference)
    keywords = entry.entry.profile&.keywords || []
    keywords.filter_map { |kw| ROLE_RANK[kw] }.min || 2
  end
end
