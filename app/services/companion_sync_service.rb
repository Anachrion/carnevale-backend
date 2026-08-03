# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Reconciles a parent entry's auto-included companion entries to match the catalog (CARNEVALEB-23):
# for each of the parent profile's `profile_companions`, the gang should hold `base_quantity` copies
# of that companion (or `upgraded_quantity` when the parent's paid upgrade is bought). Runs after the
# parent is hired and whenever its upgrade is toggled — adding the missing companion entries and
# destroying any surplus. A no-op for a profile that brings no companions.
#
# Companions are ordinary (non-summoned) entries: the Emissary's Tentacles "count towards Henchman
# taken", cost 0 Ducats of their own, and sit under the gang-building rules like any other Henchman —
# the only difference is they can't be hired or removed directly (see the controller guards).
class CompanionSyncService
  def self.call(parent_entry)
    new(parent_entry).call
  end

  def initialize(parent_entry)
    @parent = parent_entry
    @list = parent_entry.list
  end

  def call
    companions = @parent.profile&.profile_companions.to_a
    return if companions.empty?

    # One validation at the end rather than per created/destroyed child (matches the controller's
    # #spells bulk edit) — a set of Tentacles is several inserts in a row.
    Gang::List.defer_validation do
      Gang::Entry.transaction { reconcile(companions) }
    end
    @list.refresh_selection_validity
  end

  private

  def reconcile(companions)
    existing = @parent.companion_entries.reload.to_a
    by_profile_id = existing.group_by { |entry| entry.profile&.id }
    wanted_profile_ids = companions.map(&:companion_profile_id).to_set

    companions.each do |companion|
      required = @parent.upgrade_selected ? companion.upgraded_quantity : companion.base_quantity
      current = by_profile_id[companion.companion_profile_id] || []

      if current.size < required
        add(companion.companion_profile, required - current.size)
      elsif current.size > required
        current.last(current.size - required).each(&:destroy!)
      end
    end

    # A companion whose row was removed from the catalog (or a stale link) is no longer wanted —
    # drop it so the gang can't keep an orphaned auto-included model.
    existing.each do |entry|
      entry.destroy! if entry.profile && !wanted_profile_ids.include?(entry.profile.id)
    end
  end

  def add(companion_profile, count)
    # Any of the profile's card references identifies it; a companion with no printed card can't be
    # placed, so it's skipped rather than saved with a dangling entry_id.
    card_reference = companion_profile.card_references.first
    return unless card_reference

    count.times do
      @list.list_entries.create!(
        entry_type: "Catalog::CardReference",
        entry_id: card_reference.id,
        position: (@list.list_entries.maximum(:position) || 0) + 1,
        companion_of_entry: @parent
      )
    end
  end
end
