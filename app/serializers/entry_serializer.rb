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
    cantrip = @cantrips[entry.spell_discipline] if entry.spell_discipline.present?
    {
      id: entry.id,
      position: entry.position,
      entry_type: entry.entry_type,
      entry_id: entry.entry_id,
      name: entry.entry.name,
      cost: entry.cost,
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
