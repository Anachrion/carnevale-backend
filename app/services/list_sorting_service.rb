class ListSortingService
  ROLE_RANK = { "Leader" => 0, "Hero" => 1 }.freeze

  def self.call(list)
    new(list).call
  end

  def initialize(list)
    @list = list
  end

  def call
    entries = @list.list_entries.includes(card_reference: :profile).to_a
    sorted = entries.sort_by { |e| [role_rank(e), e.card_reference.cost.to_i] }
    sorted.each_with_index { |entry, index| entry.update_columns(position: -(index + 1)) }
    sorted.each_with_index { |entry, index| entry.update_columns(position: index + 1) }
  end

  private

  def role_rank(entry)
    keywords = entry.card_reference.profile&.keywords || []
    keywords.filter_map { |kw| ROLE_RANK[kw] }.min || 2
  end
end
