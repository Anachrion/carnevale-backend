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
    sorted.each_with_index { |entry, index| entry.update_columns(position: -(index + 1)) }
    sorted.each_with_index { |entry, index| entry.update_columns(position: index + 1) }
  end

  private

  def role_rank(entry)
    return 3 unless entry.entry.is_a?(CardReference)
    keywords = entry.entry.profile&.keywords || []
    keywords.filter_map { |kw| ROLE_RANK[kw] }.min || 2
  end
end
