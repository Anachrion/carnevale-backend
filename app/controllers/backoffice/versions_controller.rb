# SPDX-License-Identifier: AGPL-3.0-or-later

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
      PaperTrail.request(controller_info: { reverted_from_id: version.id }) { restore_shared(record) }

      notice = "Undid the change to #{record.name.presence || "this #{record.model_name.human.downcase}"}."
      if record.respond_to?(:cards_affected)
        affected = record.cards_affected.count
        notice += " #{affected} card#{"s" unless affected == 1} now out of date."
      end
      redirect_to edit_path_for(record), notice: notice
    end

    # Saves a reified weapon, rule, ability or spell. An ability whose name changes back is renamed
    # through Catalog::AbilityRename, so the cards listing it follow, as they did when it was
    # renamed in the first place.
    def restore_shared(record)
      current = record.class.find_by(id: record.id)
      if record.is_a?(Catalog::Ability) && current && current.name != record.name
        Catalog::AbilityRename.call(current, record.name, description: record.description)
      else
        record.save!
      end
    end

    def edit_path_for(record)
      case record
      when Catalog::Weapon then edit_backoffice_weapon_path(record)
      when Catalog::SpecialRule then edit_backoffice_special_rule_path(record)
      when Catalog::Ability then edit_backoffice_ability_path(record)
      when Catalog::Spell then edit_backoffice_spell_path(record)
      end
    end
  end
end
