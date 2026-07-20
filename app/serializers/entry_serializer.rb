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

class EntrySerializer
  # `cantrips` is the discipline => Cantrip Spell lookup, passed in so a whole list (or the games
  # index) resolves it once rather than per entry (B-P2-3).
  # `turn` is the owning player's turn cursor, passed through to EntryStateSerializer to derive
  # `activated`, and used here to derive each known/granted spell's `cast` flag; nil outside a live
  # game, where nothing reads as cast and nothing reads as activated.
  def initialize(list_entry, cantrips:, turn: nil, demoted_leader: false, promotable_leader: false)
    @entry = list_entry
    @cantrips = cantrips
    @turn = turn
    # Flex-Leader demotion, resolved once per list by ListSerializer (LeaderResolver): whether this
    # entry has lost its Leader keyword (so the client shows Hero, not Leader), and — in the ambiguous
    # "several flex Leaders, no forced Leader" case — whether the player could promote it instead.
    @demoted_leader = demoted_leader
    @promotable_leader = promotable_leader
  end

  def as_json
    entry = @entry
    profile = entry.profile
    # The card this member is hired as. A profile can have several card references, each with its
    # own illustration; which one the entry points at *is* the chosen illustration, so the client
    # needs the identifier and faces to render it and to highlight the pick among the profile's
    # alternatives. Nil for non-card entries (e.g. Equipment), which have no card face.
    card = entry.entry if entry.entry.is_a?(Catalog::CardReference)
    pools = entry.resolved_pools.map { |resolved| pool_json(resolved) }
    # A granted spell that duplicates a spell/cantrip already shown through a pool (Blood Crone's
    # Major Arcana grants all 5 Cantrips outright, one of which is also the Cantrip her own pool
    # grants once she's picked that Discipline) is the *same* spell on the wire — same key, same
    # cast state — so it's dropped from granted_spells rather than shown twice.
    known_keys = pools.flat_map { |p| p[:cantrips] + p[:spells] }.map { |s| s[:key] }.to_set
    granted_spells = profile ? profile.profile_granted_spells.flat_map { |grant| granted_spell_json(grant) } : []
    granted_spells = granted_spells.reject { |g| known_keys.include?(g[:key]) }
    {
      id: entry.id,
      position: entry.position,
      entry_type: entry.entry_type,
      entry_id: entry.entry_id,
      name: entry.entry.name,
      # The underlying profile's name, without the card-reference letter suffix (e.g. "Beggar"
      # rather than "Beggar (A)"). Lets the client label a hired model by its model name and number
      # duplicates itself, instead of showing the printed card variant. Nil for Equipment.
      profile_name: profile&.name,
      # The Doctor+Hero keywords Apprentice Doctor's Apprenticeship mentor picker filters
      # candidates by — client-side only, ListValidationService is the real enforcement.
      keywords: profile&.keywords || [],
      # Whether this Leader demotes to a plain Hero alongside another Leader (see ProfilesController)
      # — lets the builder decide whether to still offer a Leader model once one is in the list.
      flexible_leader: profile&.flexible_leader || false,
      # This flex Leader has been demoted to a plain Hero by the gang's composition (it prints Leader
      # but lost it); the client shows Hero and never pins it as the Leader.
      demoted_leader: @demoted_leader,
      # A demoted flex Leader the player could promote to Leader instead (only in the ambiguous case
      # of several unconditional flex Leaders and no forced Leader). The client shows a "promote" action.
      promotable_leader: @promotable_leader,
      cost: entry.cost,
      # The chosen card reference (illustration), mirroring the shape ProfilesController exposes
      # under `card_references` so the client can match this entry to one of them.
      identifier: card&.identifier,
      card_front: card&.card_front,
      card_back: card&.card_back,
      # Conjured mid-game by a special rule rather than hired. Costs the gang nothing and is exempt
      # from the gang-building rules; the client marks it and offers to remove it again.
      summoned: entry.summoned,
      # Only present once the game has started (Encounter::Game#start!); nil beforehand
      # and for equipment entries, which have no HP/WP/CP to track.
      state: entry.entry_state && EntryStateSerializer.new(entry.entry_state, turn: @turn).as_json,
      # Spell selection (rulebook p24, generalized for CARNEVALEB-47). `mage` gates the Spells
      # button in the gang builder; non-Mage entries carry mage: false and empty pools/granted_spells.
      mage: profile&.mage? || false,
      # Apprentice Doctor's Apprenticeship: which other entry in the same gang she's copying Mage
      # access from, or null. Irrelevant (always null) for every other profile.
      mentored_by_entry_id: entry.mentored_by_entry_id,
      # Romani's Tarot: whether multiple copies of this profile in the same gang must each pick a
      # different Discipline — lets the picker grey out a sibling's already-chosen Discipline
      # without the client needing to know which profiles carry this rule.
      distinct_discipline_per_copy: profile&.distinct_discipline_per_copy? || false,
      pools: pools,
      granted_spells: granted_spells
    }
  end

  private

  def pool_json(resolved)
    pool = resolved[:pool]
    cantrips = pool.grants_cantrip? ? resolved[:chosen_disciplines].filter_map { |d| @cantrips[d] } : []

    {
      id: pool.id,
      of: resolved[:of],
      slot_count: resolved[:slot_count],
      # The Mage(X)-only portion of this pool's *own* slot_count (not the resolved one above) —
      # relevant only when this entry is itself a mentor candidate, so the client can read it off a
      # sibling entry when populating Apprentice Doctor's Apprenticeship picker.
      mage_slot_count: pool.mage_slot_count,
      unlimited: pool.unlimited?,
      grants_cantrip: pool.grants_cantrip?,
      mentor_derived: pool.mentor_derived?,
      distinct_from_other_pools: pool.distinct_from_other_pools?,
      resets_each_round: pool.resets_each_round?,
      rule: rule_json(pool.special_rule),
      eligible_disciplines: resolved[:eligible_disciplines],
      chosen_disciplines: resolved[:chosen_disciplines],
      cantrips: cantrips.map { |spell| spell_json(spell, resets_each_round: pool.resets_each_round?) },
      spells: resolved[:spells].map { |spell| spell_json(spell, resets_each_round: pool.resets_each_round?) }
    }
  end

  # all_cantrips (Blood Crone's Major Arcana) expands to one entry per discipline's Cantrip rather
  # than a single named spell — the only grant_kind that returns more than one item. Each keyed by
  # its own spell id (not the grant's), so marking one cast in-game doesn't mark all five.
  def granted_spell_json(grant)
    if grant.grant_kind == "all_cantrips"
      # spell_json's shape (shared with pool spells) is missing 3 fields GrantedSpell always
      # requires on the wire — merge them in rather than duplicating spell_json here.
      return @cantrips.values.map do |spell|
        spell_json(spell, resets_each_round: grant.resets_each_round?).merge(
          consumes_slot: grant.consumes_slot?,
          resets_each_round: grant.resets_each_round?,
          rule: rule_json(grant.special_rule)
        )
      end
    end

    # A real Catalog::Spell (Galilean Priest's Waves of Force) is keyed by its own spell id, same as
    # any pool-picked spell; a character-unique spell (no Catalog::Spell row) has nothing to key by
    # except the grant itself.
    key = grant.spell_id ? spell_key(grant.spell) : grant_key(grant)
    [ {
      key: key,
      id: grant.spell_id,
      discipline: grant.spell&.discipline,
      name: grant.resolved_name,
      cost: grant.resolved_cost,
      difficulty: grant.resolved_difficulty,
      description: grant.resolved_description,
      cantrip: grant.spell&.cantrip || false,
      consumes_slot: grant.consumes_slot?,
      resets_each_round: grant.resets_each_round?,
      rule: rule_json(grant.special_rule),
      cast: cast?(key, grant.resets_each_round?)
    } ]
  end

  # `key` identifies this spell for PATCH .../spell_casts (see #spell_key) — included on the wire
  # rather than left for the client to reconstruct, since a character-unique granted spell (see
  # #granted_spell_json) has no spell id to build one from.
  def spell_json(spell, resets_each_round:)
    SpellSerializer.new(spell).as_json.merge(key: spell_key(spell), cast: cast?(spell_key(spell), resets_each_round))
  end

  def spell_key(spell) = "spell:#{spell.id}"
  def grant_key(grant) = "granted:#{grant.id}"

  def cast?(key, resets_each_round)
    return false unless @entry.entry_state

    @entry.entry_state.spell_cast?(key, resets_each_round: resets_each_round, current_turn: @turn)
  end

  def rule_json(special_rule)
    return nil unless special_rule

    { name: special_rule.name, description: special_rule.description }
  end
end
