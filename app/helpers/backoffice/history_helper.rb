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
  # Labels for the catalog history pages (CARNEVALEB-81).
  module HistoryHelper
    KIND_LABELS = {
      "Catalog::Profile" => "Card", "Catalog::Weapon" => "Weapon", "Catalog::SpecialRule" => "Special rule"
    }.freeze

    EVENT_LABELS = {
      "create" => "Created", "update" => "Edited", "destroy" => "Deleted",
      "revert" => "Reverted", "baseline" => "History started"
    }.freeze

    def history_kind(version)
      KIND_LABELS.fetch(version.item_type, version.item_type)
    end

    # A weapon reverted through paper_trail is an ordinary update; reverted_from_id is what tells it
    # apart.
    def history_event(version)
      return "Reverted" if version.reverted_from_id.present?

      EVENT_LABELS.fetch(version.event, version.event.humanize)
    end

    def history_author(version, authors)
      return "system" if version.whodunnit.blank?

      authors.fetch(version.whodunnit, "user ##{version.whodunnit}")
    end

    # The record's current name, linked to its editor; a deleted weapon or rule falls back to the
    # name it had, unlinked.
    def history_record(version)
      item = version.item
      name = item&.name.presence ||
             version.card_snapshot&.dig("attributes", "name") ||
             version.object&.dig("name").presence ||
             "#{history_kind(version)} ##{version.item_id}"
      return name if item.nil?

      case item
      when Catalog::Profile then link_to(name, history_backoffice_profile_path(item))
      when Catalog::Weapon then link_to(name, edit_backoffice_weapon_path(item))
      when Catalog::SpecialRule then link_to(name, edit_backoffice_special_rule_path(item))
      end
    end

    # A card version restores the card as it was after that save; a weapon or rule version is
    # undone, restoring the record as it was before that change.
    def history_revert_button(version)
      return unless Catalog::History.revertable?(version)

      if version.item_type == "Catalog::Profile"
        label = "Restore this version"
        confirm = "Restore this card to how it was after this change? Every field, weapon, rule and spell is restored."
      else
        label = "Undo this change"
        confirm = "Restore this #{history_kind(version).downcase} to how it was before this change? " \
                  "Later changes to it are undone too, and every card carrying it goes out of date."
      end

      button_to label, revert_backoffice_version_path(version),
        class: "btn text-xs", form: { class: "inline" }, data: { turbo_confirm: confirm }
    end
  end
end
