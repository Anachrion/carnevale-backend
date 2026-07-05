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
