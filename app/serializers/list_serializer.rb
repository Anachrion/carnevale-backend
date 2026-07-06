# The full gang list with its entries. Pass a shared `cantrips` lookup when rendering many lists
# in one request (e.g. the lists index) so it isn't rebuilt per list (B-P2-3).
class ListSerializer
  def initialize(list, cantrips: nil)
    @list = list
    @cantrips = cantrips
  end

  def as_json
    entries = list_entries_for_render
    {
      id: @list.id,
      # The source list this was snapshotted from (null for a source list itself) — lets the client
      # match a player's in-game gang back to the entry in their available-lists picker.
      source_list_id: @list.source_list_id,
      name: @list.name,
      faction: @list.faction,
      points: @list.points,
      # Sum over the already-materialised, profile-preloaded entries so total_cost costs no extra
      # queries and doesn't re-trigger the per-entry profile lookup (B-P2-2).
      total_cost: entries.sum { |e| e.cost.to_i },
      selection_valid: @list.selection_valid,
      selection_errors: @list.selection_errors,
      entries: entries.map { |entry| EntrySerializer.new(entry, cantrips: cantrips).as_json }
    }
  end

  private

  def cantrips
    @cantrips ||= Catalog::Spell.cantrips.index_by(&:discipline)
  end

  # Loads the entries with everything EntrySerializer needs preloaded: the polymorphic `entry`, its
  # `entry_state` and `entry_spells`, and — since `entry` is polymorphic and only card references
  # carry a profile — the `profile` behind each card reference, preloaded in one query. Without that
  # last step EntrySerializer would hit CardReference#profile once per entry (the B-P2-1 N+1).
  def list_entries_for_render
    entries = @list.list_entries
                   .includes(:entry, :entry_state, entry_spells: :spell)
                   .order(:position)
                   .to_a
    card_references = entries.map(&:entry).grep(Catalog::CardReference)
    if card_references.any?
      ActiveRecord::Associations::Preloader.new(records: card_references, associations: :profile).call
    end
    entries
  end
end
