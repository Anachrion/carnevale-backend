# CARNEVALEB-47: the ~10 profiles whose spell-selection mechanics deviate from the standard
# "one pool, one discipline" shape SpellPoolBackfill covers. Idempotent — replace_spell_pools!/
# replace_granted_spells! always fully replace a profile's set, so re-running this reapplies the
# same configuration rather than duplicating it. Run once after `rails db:seed` (or the equivalent
# one-time migration backfill against existing production data).
namespace :spell_pools do
  desc "Configure the exception profiles whose spell pools/grants aren't the standard one-pool shape"
  task configure_exceptions: :environment do
    def profile!(name)
      Catalog::Profile.find_by!(name: name)
    end

    def rule!(name)
      Catalog::SpecialRule.find_by!(name: name)
    end

    # The two character-unique spells were authored as special rules with a blank `name` (see
    # Catalog::SpecialRule's comment) — found by their spell_name instead.
    def unique_spell_rule!(spell_name)
      Catalog::SpecialRule.find_by!(spell_name: spell_name)
    end

    # ── Doctor of the Firmament — Aetheric Gaze ──────────────────────────────────────
    # One pool spanning 2 of her 3 listed Disciplines at once, cantrips from both chosen.
    profile!("Doctor of the Firmament").replace_spell_pools!([ {
      of: 2, slot_count: 4, mage_slot_count: 2, grants_cantrip: true, resets_each_round: true,
      special_rule_id: rule!("Aetheric Gaze").id,
      disciplines: %w[blood_rites fateweaving wild_magic]
    } ])

    # ── Seamstress — Entwined Magics ─────────────────────────────────────────────────
    # Base Mage(1) spell from one discipline (grants its Cantrip); Expert Sorcerer(1) bonus spell
    # may come from the *other* listed discipline instead, with no extra Cantrip either way.
    profile!("Seamstress").replace_spell_pools!([
      { of: 1, slot_count: 1, mage_slot_count: 1, grants_cantrip: true, resets_each_round: true,
        disciplines: %w[divinity fateweaving] },
      { of: 1, slot_count: 1, mage_slot_count: 0, grants_cantrip: false, resets_each_round: true,
        special_rule_id: rule!("Entwined Magics").id, disciplines: %w[divinity fateweaving] }
    ])

    # ── Tarot Reader — Minor Arcana ──────────────────────────────────────────────────
    # Normal Mage(2)+Expert Sorcerer(1) pool, plus a mandatory *extra* Cantrip from a different
    # available Discipline — modeled as a second pool with 0 regular slots that only grants a
    # Cantrip. (Not enforced: that the second pool's chosen Discipline actually differs from the
    # first's — left as a picker-UI nudge rather than a hard validation, see CARNEVALEB-47 plan.)
    profile!("Tarot Reader").replace_spell_pools!([
      { of: 1, slot_count: 3, mage_slot_count: 2, grants_cantrip: true, resets_each_round: true,
        disciplines: %w[fateweaving runes_of_sovereignty wild_magic] },
      { of: 1, slot_count: 0, grants_cantrip: true, resets_each_round: true,
        distinct_from_other_pools: true,
        special_rule_id: rule!("Minor Arcana").id, disciplines: %w[fateweaving runes_of_sovereignty wild_magic] }
    ])

    # ── Apprentice Doctor — Apprenticeship (Mage branch only, see CARNEVALEB-47 scope) ──
    # No static disciplines of her own — resolved at selection time from whichever Hero+Doctor
    # mentor the player chooses (Gang::Entry#mentored_by_entry_id).
    profile!("Apprentice Doctor").replace_spell_pools!([ {
      of: 1, slot_count: 0, mentor_derived: true, grants_cantrip: true, resets_each_round: true,
      special_rule_id: rule!("Apprenticeship").id, disciplines: []
    } ])

    # ── The Drowned Nun — Dagonite Baptism ───────────────────────────────────────────
    # Standard pool untouched; Dagonite Baptism is known "in addition to any other spells" — a
    # character-unique, discipline-less spell, at no quota cost.
    profile!("The Drowned Nun").replace_granted_spells!([ {
      grant_kind: "named_spell", consumes_slot: false, resets_each_round: true,
      special_rule_id: unique_spell_rule!("Dagonite Baptism").id,
      unique_spell_name: "Dagonite Baptism", unique_spell_cost: 1, unique_spell_difficulty: 6,
      unique_spell_description: "Total up every Ace rolled then pick one enemy character in line " \
        "of sight within 3\". That character loses that many Life Points plus 1."
    } ])

    # ── Maria Fioritura — Creative Creation ──────────────────────────────────────────
    # Standard pool untouched; confirmed additive (doesn't consume a Mage(2) slot).
    profile!("Maria Fioritura").replace_granted_spells!([ {
      grant_kind: "named_spell", consumes_slot: false, resets_each_round: true,
      special_rule_id: unique_spell_rule!("Creative Creation").id,
      unique_spell_name: "Creative Creation", unique_spell_cost: 2, unique_spell_difficulty: 7,
      unique_spell_description: "Place 1 Painted Protector anywhere within 3\" of this character. " \
        "A Painted Protector counts as a friendly character and may take a turn that round as normal."
    } ])

    # ── Galilean Priest — Water Affinity ─────────────────────────────────────────────
    # Standard pool untouched; always additionally knows Waves of Force, a real catalog spell from
    # Runes of Sovereignty — a Discipline she has no other access to. (The water-casting override
    # in the same rule is a runtime mechanic, out of scope here.)
    profile!("Galilean Priest").replace_granted_spells!([ {
      grant_kind: "named_spell", consumes_slot: false, resets_each_round: true,
      special_rule_id: rule!("Water Affinity").id,
      spell_id: Catalog::Spell.find_by!(name: "Waves of Force").id
    } ])

    # ── Blood Crone — Major Arcana ───────────────────────────────────────────────────
    # Standard pool untouched; always knows all 5 Cantrips regardless of Discipline access — the
    # list-building fact only (Minor Incantata's free 0AP cast is a runtime mechanic, out of scope).
    profile!("Blood Crone").replace_granted_spells!([ {
      grant_kind: "all_cantrips", consumes_slot: false, resets_each_round: true,
      special_rule_id: rule!("Major Arcana").id
    } ])

    # ── Adventuring Noble — Arcane Totem ─────────────────────────────────────────────
    # Knows every spell of her one Discipline automatically (no picks). The 0WP cost override and
    # cascading-loss-on-fail are runtime mechanics, out of scope; "once per game" (not per round) is
    # modeled via resets_each_round: false.
    profile!("Adventuring Noble").replace_spell_pools!([ {
      of: 1, slot_count: 0, unlimited: true, grants_cantrip: true, resets_each_round: false,
      special_rule_id: rule!("Arcane Totem").id, disciplines: %w[wild_magic]
    } ])

    # ── Romani — Tarot ────────────────────────────────────────────────────────────────
    # Her pool is already the standard shape from the backfill (Mage(0): 0 slots, Cantrip only,
    # all 4 non-Divinity Disciplines eligible) — only two changes needed: link the pool to its
    # explaining rule, and flag the profile for the new gang-composition check (enforced in
    # ListValidationService#check_distinct_discipline_per_copy, not here).
    romani = profile!("Romani")
    romani.update!(distinct_discipline_per_copy: true)
    pool = romani.profile_spell_pools.first
    pool.update!(special_rule_id: rule!("Tarot").id) if pool

    puts "Configured spell pools/grants for the 10 exception profiles."
  end
end
