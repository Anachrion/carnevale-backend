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
    check_distinct_discipline_per_copy
    check_mentor_eligibility
    @errors.empty?
  end

  def errors
    @errors ||= []
  end

  # Every list entry, loaded once with everything the checks below read preloaded — so the whole
  # validation runs on one in-memory set instead of re-querying the entries (with its own
  # `includes`) inside four separate checks, each re-triggering a per-entry profile lookup. This is
  # the single hot path `refresh_selection_validity` runs after every list edit, so the query count
  # it costs scales straight into how snappy add/remove feels.
  def list_entries
    @list_entries ||= begin
      loaded = @list.list_entries
                    .includes(:entry, :entry_pool_disciplines, entry_spells: :spell, mentored_by_entry: :entry)
                    .to_a
      # `entry` is polymorphic, so a card reference's `profile` (and that profile's spell pools) can't
      # ride the `includes` above — preload it in one pass over the card references, both the entries'
      # own and their mentors', exactly as ListSerializer does. resolved_pools and the keyword checks
      # read these, and without the preload each read is a query per entry (the old N+1).
      card_refs = (loaded.map(&:entry) + loaded.filter_map { |e| e.mentored_by_entry&.entry }).grep(Catalog::CardReference)
      if card_refs.any?
        ActiveRecord::Associations::Preloader.new(
          records: card_refs,
          associations: { profile: { profile_spell_pools: :profile_spell_pool_disciplines } }
        ).call
      end
      loaded
    end
  end

  # Every rule below is a gang-*building* rule — the ducat limit, faction consistency, unique models,
  # the Leader count, the Hero/Henchman ratio. None of them has anything to say about a model
  # conjured onto the board mid-battle by a special rule, so summoned entries are excluded outright:
  # otherwise a legal summon would push the gang over its limit and flip it to invalid.
  def projected_items
    # `.compact`: the entry association is polymorphic, so it has no FK and a catalog row deleted
    # from under it leaves `entry` nil. Dropping those here keeps every check below (and the
    # after_commit revalidation they run in) from raising on `nil.cost`/`nil.name` and bricking all
    # edits to the list (B-26). An orphaned entry is broken data; ignoring it is safe and non-fatal.
    @projected_items ||= list_entries.reject(&:summoned?).map(&:entry).compact
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
    # Group by profile, not card-reference id: a Unique model fielded via two *different* references
    # of the same profile (an A/B pair, or a repointed illustration) is still the same character
    # hired twice, and must be flagged (B-25).
    unique_refs.group_by(&:profile_id).each do |_, refs|
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

  # Enforces the spell-selection rules per pool (rulebook p24, generalized for CARNEVALEB-47's
  # exceptions): only Mages may know spells, each pool's committed discipline(s) must be a subset of
  # that pool's eligible set and respect its `of` count, every spell known through a pool must share
  # one of that pool's committed disciplines, and the non-Cantrip spell count can't exceed the
  # pool's slot_count (an `unlimited` pool has nothing to check — it auto-knows everything).
  def check_spell_selections
    list_entries.each do |list_entry|
      next if list_entry.entry.nil? # orphaned entry (see projected_items) — skip, don't raise
      # Checked on the entry's own raw associations, not #resolved_pools: a non-Mage profile has no
      # pools at all, so resolved_pools is always [] for it — relying on that here would silently
      # skip a non-Mage entry with spell data wrongly attached instead of catching it below.
      next if list_entry.entry_pool_disciplines.empty? && list_entry.entry_spells.empty?

      name = list_entry.entry.name
      profile = list_entry.profile

      unless profile&.mage?
        @errors << "#{name} cannot know spells because it is not a Mage"
        next
      end

      resolved_pools = list_entry.resolved_pools
      resolved_pools.each { |r| check_pool_selection(name, r) }
      check_distinct_from_other_pools(name, resolved_pools)
    end
  end

  # Tarot Reader's Minor Arcana ("1 additional Cantrip... from a different available Discipline"):
  # any pool flagged distinct_from_other_pools must not share a chosen Discipline with any other
  # pool on the same entry — generalized rather than hardcoded to a specific pool pairing, so it
  # covers any future profile with the same "bonus pool, different Discipline" shape.
  def check_distinct_from_other_pools(name, resolved_pools)
    resolved_pools.each do |resolved|
      next unless resolved[:pool].distinct_from_other_pools?

      others = resolved_pools.reject { |r| r[:pool].id == resolved[:pool].id }.flat_map { |r| r[:chosen_disciplines] }
      overlap = resolved[:chosen_disciplines] & others
      next if overlap.empty?

      @errors << "#{name} must pick a different Discipline for this pool (#{overlap.map(&:humanize).join(', ')} already used)"
    end
  end

  def check_pool_selection(name, resolved)
    pool = resolved[:pool]
    return if pool.unlimited? # nothing to pick — every spell of the discipline is known already

    chosen = resolved[:chosen_disciplines]
    eligible = resolved[:eligible_disciplines]

    off_eligible = chosen - eligible
    if off_eligible.any?
      @errors << "#{name} cannot use the #{off_eligible.map(&:humanize).join(', ')} Discipline(s)"
    end

    if chosen.size > resolved[:of]
      @errors << "#{name} can only pick #{resolved[:of]} Discipline(s) for this pool (chose #{chosen.size})"
    end

    known_spells = resolved[:spells]
    off_discipline = known_spells.reject { |spell| chosen.include?(spell.discipline) }
    if off_discipline.any?
      @errors << "#{name} can only know spells from its committed Discipline(s) for this pool"
    end

    known_count = known_spells.count { |spell| !spell.cantrip }
    if known_count > resolved[:slot_count]
      @errors << "#{name} knows too many spells (#{known_count}/#{resolved[:slot_count]})"
    end
  end

  # Romani's Tarot: multiple copies of a `distinct_discipline_per_copy` profile in the same gang
  # must each commit to a different Discipline from every other copy (their first pool only — no
  # profile with this flag has more than one).
  def check_distinct_discipline_per_copy
    entries = list_entries.select { |e| e.profile&.distinct_discipline_per_copy? }
    entries.group_by { |e| e.profile.id }.each_value do |copies|
      next if copies.size <= 1

      chosen = copies.filter_map { |entry| entry.resolved_pools.first&.dig(:chosen_disciplines)&.first }
      duplicates = chosen.tally.select { |_, count| count > 1 }.keys
      next if duplicates.empty?

      @errors << "#{copies.first.entry.name}: only one copy may pick each Discipline (#{duplicates.map(&:humanize).join(', ')} repeated)"
    end
  end

  # Apprentice Doctor's Apprenticeship: the mentor must carry both the Hero and Doctor keywords,
  # and a given mentor can only ever mentor one Apprentice Doctor ("A character can only be a
  # mentor to one Apprentice Doctor").
  def check_mentor_eligibility
    entries_with_mentor = list_entries.select(&:mentored_by_entry)

    entries_with_mentor.each do |list_entry|
      next if list_entry.entry.nil?

      keywords = list_entry.mentored_by_entry.profile&.keywords || []
      next if keywords.include?("Hero") && keywords.include?("Doctor")

      @errors << "#{list_entry.entry.name}'s mentor must have both the Hero and Doctor keywords"
    end

    entries_with_mentor.group_by(&:mentored_by_entry_id).each_value do |apprentices|
      next if apprentices.size <= 1

      mentor_name = apprentices.first.mentored_by_entry.entry&.name
      names = apprentices.filter_map { |e| e.entry&.name }.join(", ")
      @errors << "#{mentor_name} can only mentor one Apprentice Doctor (currently mentoring #{names})"
    end
  end
end
