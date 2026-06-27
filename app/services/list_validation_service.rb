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
    @errors.empty?
  end

  def errors
    @errors ||= []
  end

  private

  def projected_references
    @projected_references ||= begin
      refs = @list.card_references.includes(:profile).to_a
      @adding ? refs + [@adding] : refs
    end
  end

  def check_points_limit
    total = projected_references.sum { |cr| cr.cost.to_i }
    return if total <= @list.points

    @errors << "total cost (#{total}) exceeds the #{@list.points} points limit"
  end

  def check_faction_consistency
    projected_references.each do |cr|
      next if cr.faction == @list.faction || cr.faction == "gifted"

      @errors << "#{cr.name} belongs to the #{cr.faction} faction and cannot join a #{@list.faction} list"
    end
  end

  def check_unique_constraint
    unique_refs = projected_references.select { |cr| cr.profile&.keywords&.include?("Unique") }
    unique_refs.group_by(&:id).each do |_, refs|
      @errors << "#{refs.first.name} is Unique and can only be hired once" if refs.size > 1
    end
  end
end
