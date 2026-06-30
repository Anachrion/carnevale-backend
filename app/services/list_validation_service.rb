class ListValidationService
  def initialize(list, adding: nil)
    @list = list
    @adding = adding
  end

  def self.call(list, adding: nil)
    new(list, adding: adding).call
  end

  def call
    success = valid?
    { success: success, errors: errors }
  end

  private

  def valid?
    @errors = []
    check_points_limit
    check_faction_consistency
    check_unique_constraint
    check_equipment_uniqueness
    check_leader_count
    check_hero_henchman_ratio
    @errors.empty?
  end

  def errors
    @errors ||= []
  end

  def projected_items
    @projected_items ||= begin
      items = @list.list_entries.includes(:entry).map(&:entry)
      @adding ? items + [@adding] : items
    end
  end

  def projected_card_references
    @projected_card_references ||= projected_items.grep(CardReference)
  end

  def check_points_limit
    total = projected_items.sum { |item| item.cost.to_i }
    return if total <= @list.points

    @errors << "total cost (#{total}) exceeds the #{@list.points} points limit"
  end

  def check_faction_consistency
    projected_card_references.each do |cr|
      next if cr.faction == @list.faction || cr.faction == "gifted"

      @errors << "#{cr.name} belongs to the #{cr.faction} faction and cannot join a #{@list.faction} list"
    end
  end

  def check_unique_constraint
    unique_refs = projected_card_references.select { |cr| cr.profile&.keywords&.include?("Unique") }
    unique_refs.group_by(&:id).each do |_, refs|
      @errors << "#{refs.first.name} is Unique and can only be hired once" if refs.size > 1
    end
  end

  def check_equipment_uniqueness
    projected_items.grep(Equipment).group_by(&:id).each do |_, items|
      @errors << "#{items.first.name} can only be taken once" if items.size > 1
    end
  end

  def check_leader_count
    return if projected_items.empty?
    return if @list.points <= 75

    leader_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Leader") }
    @errors << "the gang must have exactly one Leader (found #{leader_count})" unless leader_count == 1
  end

  def check_hero_henchman_ratio
    hero_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Hero") }
    henchman_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Henchman") }
    return if hero_count <= henchman_count

    @errors << "the gang cannot have more Heroes (#{hero_count}) than Henchmen (#{henchman_count})"
  end
end
