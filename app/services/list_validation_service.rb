class ListValidationService
  # Gangs at or below this ducat limit are small skirmish forces and are exempt from the
  # exactly-one-Leader requirement (rulebook: a warband must include a Leader once it grows past
  # this size).
  LEADER_REQUIRED_ABOVE_POINTS = 75

  def initialize(list)
    @list = list
  end

  def self.call(list)
    new(list).call
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
    check_spell_selections
    @errors.empty?
  end

  def errors
    @errors ||= []
  end

  def projected_items
    @projected_items ||= @list.list_entries.includes(:entry).map(&:entry)
  end

  def projected_card_references
    @projected_card_references ||= projected_items.grep(Catalog::CardReference)
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
    projected_items.grep(Catalog::Equipment).group_by(&:id).each do |_, items|
      @errors << "#{items.first.name} can only be taken once" if items.size > 1
    end
  end

  def check_leader_count
    return if projected_items.empty?
    return if @list.points <= LEADER_REQUIRED_ABOVE_POINTS

    leader_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Leader") }
    @errors << "the gang must have exactly one Leader (found #{leader_count})" unless leader_count == 1
  end

  def check_hero_henchman_ratio
    hero_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Hero") }
    henchman_count = projected_card_references.count { |cr| cr.profile&.keywords&.include?("Henchman") }
    return if hero_count <= henchman_count

    @errors << "the gang cannot have more Heroes (#{hero_count}) than Henchmen (#{henchman_count})"
  end

  # Enforces the spell-selection rules (rulebook p24): only Mages may know spells, every known
  # spell must come from the model's committed Discipline (one of those listed in its Discipline
  # keyword), and the number of non-Cantrip spells cannot exceed Mage (X) + Expert Sorcerer (X).
  def check_spell_selections
    @list.list_entries.includes(entry_spells: :spell).each do |list_entry|
      spells = list_entry.entry_spells.map(&:spell)
      discipline = list_entry.spell_discipline
      next if spells.empty? && discipline.blank?

      name = list_entry.entry.name
      profile = list_entry.profile

      unless profile&.mage?
        @errors << "#{name} cannot know spells because it is not a Mage"
        next
      end

      if discipline.present? && !profile.disciplines.include?(discipline)
        @errors << "#{name} cannot use the #{discipline.humanize} Discipline"
      end

      off_discipline = spells.reject { |spell| spell.discipline == discipline }
      if discipline.present? && off_discipline.any?
        @errors << "#{name} can only know #{discipline.humanize} spells; all spells must share one Discipline"
      end

      known = spells.count { |spell| !spell.cantrip }
      if known > profile.spell_slots
        @errors << "#{name} knows too many spells (#{known}/#{profile.spell_slots})"
      end
    end
  end
end
