# Creates one standard spell pool (of: 1, grants_cantrip: true, resets_each_round: true) per mage
# profile that doesn't have one yet, parsed from its existing "Mage (X)" / "Expert Sorcerer (X)" /
# "Discipline (A, B)" text. Idempotent — skips any profile that already has a pool — so it's safe
# to call both from the one-time migration (existing production, where profiles already exist) and
# from db:seed (a fresh install, where profiles only exist once CatalogSnapshot.import runs, which
# happens *after* migrations do). See CARNEVALEB-47.
module SpellPoolBackfill
  MAGE_ABILITY = /\AMage \((\d+)\)\z/
  EXPERT_SORCERER_ABILITY = /\AExpert Sorcerer \((\d+)\)\z/
  DISCIPLINE_KEYWORD = /\ADiscipline \((.+)\)\z/

  def self.call
    already_has_pool = Catalog::ProfileSpellPool.distinct.pluck(:profile_id).to_set
    backfilled = 0

    Catalog::Profile.find_each do |profile|
      next if already_has_pool.include?(profile.id)

      backfilled += 1 if call_for(profile)
    end

    backfilled
  end

  # Backfills a single profile; returns true if a pool was created, false if it already had one or
  # isn't a Mage. Also used by the :profile factory (spec/factories/profiles.rb) so any spec
  # building a profile with "Mage (X)" text gets a real pool wired up exactly like production,
  # without hand-rolling one per spec.
  def self.call_for(profile)
    return false if profile.profile_spell_pools.exists?

    mage_level = profile.abilities.filter_map { |a| a[MAGE_ABILITY, 1]&.to_i }.first
    return false unless mage_level

    expert_sorcerer_level = profile.abilities.filter_map { |a| a[EXPERT_SORCERER_ABILITY, 1]&.to_i }.first || 0
    discipline_keyword = profile.keywords.grep(DISCIPLINE_KEYWORD).first
    disciplines = discipline_keyword ? discipline_keyword[DISCIPLINE_KEYWORD, 1].split(",").map { |n| n.strip.parameterize(separator: "_") } : []

    profile.replace_spell_pools!([ {
      of: 1, slot_count: mage_level + expert_sorcerer_level, mage_slot_count: mage_level, unlimited: false,
      grants_cantrip: true, resets_each_round: true, mentor_derived: false,
      disciplines: disciplines
    } ])
    true
  end
end
