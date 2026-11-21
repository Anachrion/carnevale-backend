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

module Backoffice
  # Reverting one version of the catalog history (CARNEVALEB-81). A revert is itself a change: it is
  # recorded, attributed, and can be reverted in turn.
  class VersionsController < BaseController
    # POST /backoffice/versions/:id/revert
    def revert
      version = PaperTrail::Version.where(item_type: Catalog::History::TRACKED_TYPES).find(params.expect(:id))
      raise ActiveRecord::RecordNotFound unless Catalog::History.revertable?(version)

      if version.item_type == "Catalog::Profile"
        revert_card(version)
      else
        revert_shared(version)
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_back fallback_location: backoffice_history_path,
        alert: "Could not revert: #{e.record.errors.full_messages.to_sentence}"
    end

    private

    # A card version holds the whole card as it stood after that save; restoring it writes every
    # field, weapon, rule and spell back through the same paths the editor uses.
    def revert_card(version)
      profile = Catalog::Profile.find(version.item_id)
      skipped = []
      recorded = nil

      Catalog::Profile.transaction do
        before = Catalog::CardSnapshot.capture(profile)
        skipped = Catalog::CardSnapshot.restore!(profile, version.card_snapshot)
        recorded = Catalog::History.record!(profile, event: "revert", before: before, reverted_from: version)
      end

      if recorded.nil?
        redirect_to history_backoffice_profile_path(profile), notice: "#{profile.name} is already in that state."
        return
      end

      # As after a normal save: the stats feed gang validation, and the card is now out of date.
      profile.refresh_dependent_list_validity!
      notice = "Restored #{profile.name} to its version of #{l(version.created_at, format: :short)}. " \
               "Its card is now out of date — render it to publish the change."
      alert = "No longer in the catalog, so not restored: #{skipped.to_sentence}." if skipped.any?
      redirect_to history_backoffice_profile_path(profile), notice: notice, alert: alert
    end

    # A weapon or special rule version is paper_trail's own: reify gives the record as it stood
    # *before* that change (or before it was deleted), so this undoes the change.
    def revert_shared(version)
      record = version.reify
      PaperTrail.request(controller_info: { reverted_from_id: version.id }) { record.save! }

      path = record.is_a?(Catalog::Weapon) ? edit_backoffice_weapon_path(record) : edit_backoffice_special_rule_path(record)
      affected = record.cards_affected.count
      redirect_to path, notice: "Undid the change to #{record.name.presence || "this rule"}. " \
                                "#{affected} card#{"s" unless affected == 1} now out of date."
    end
  end
end
