class EntrySerializer
  # `cantrips` is the discipline => cantrip Spell lookup, passed in so a whole list (or the games
  # index) resolves it once rather than per entry (B-P2-3).
  # `turn` is the owning player's turn cursor, passed through to EntryStateSerializer to derive
  # `activated`; nil outside a live game.
  def initialize(list_entry, cantrips:, turn: nil)
    @entry = list_entry
    @cantrips = cantrips
    @turn = turn
  end

  def as_json
    entry = @entry
    profile = entry.profile
    # The card this member is hired as. A profile can have several card references, each with its
    # own illustration; which one the entry points at *is* the chosen illustration, so the client
    # needs the identifier and faces to render it and to highlight the pick among the profile's
    # alternatives. Nil for non-card entries (e.g. Equipment), which have no card face.
    card = entry.entry if entry.entry.is_a?(Catalog::CardReference)
    cantrip = @cantrips[entry.spell_discipline] if entry.spell_discipline.present?
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
      # Spell selection (rulebook p24). `mage` gates the Spells button in the gang builder;
      # non-Mage entries carry mage: false and no disciplines/spells.
      mage: profile&.mage? || false,
      spell_slots: profile&.spell_slots || 0,
      disciplines: profile&.disciplines || [],
      spell_discipline: entry.spell_discipline,
      cantrip: cantrip && SpellSerializer.new(cantrip).as_json,
      spells: entry.entry_spells.map { |es| SpellSerializer.new(es.spell).as_json }
    }
  end
end
