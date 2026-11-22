# SPDX-License-Identifier: AGPL-3.0-or-later

module Catalog
  # The catalog's change history (CARNEVALEB-81): who changed which card, weapon or special rule,
  # and what changed. Stored in paper_trail's `versions` table.
  #
  # Weapons and special rules are versioned by paper_trail on its own (field-level object_changes).
  # Profiles are not: a card is recorded here, explicitly, once the backoffice has saved it *and*
  # rewritten its weapons, rules and spells, as a whole-card snapshot (Catalog::CardSnapshot).
  module History
    TRACKED_TYPES = %w[Catalog::Profile Catalog::Weapon Catalog::SpecialRule Catalog::Ability Catalog::Spell].freeze

    # Columns too noisy to show in a weapon or rule's change list.
    HIDDEN_CHANGES = %w[id created_at updated_at].freeze

    module_function

    # Records a version of `profile` as it now stands. `before` is the snapshot taken before the
    # edit: when the card has no history yet (every card, the first time it is edited after this
    # shipped), it is written first as a "baseline", so the first diff shows what the edit changed.
    #
    # Nothing is written for an edit that changed nothing. Returns the version, or nil.
    def record!(profile, event:, before: nil, reverted_from: nil)
      after = CardSnapshot.capture(profile)
      previous = versions_for(profile).last&.card_snapshot

      if previous.nil? && before && event != "create"
        return if before == after

        write!(profile, event: "baseline", snapshot: before, whodunnit: nil)
        previous = before
      end
      return if event != "create" && previous == after

      write!(profile, event: event, snapshot: after, whodunnit: PaperTrail.request.whodunnit,
        reverted_from_id: reverted_from&.id)
    end

    def versions_for(record)
      PaperTrail::Version.where(item_type: record.class.base_class.name, item_id: record.id).order(:created_at, :id)
    end

    def recent(limit: 100)
      PaperTrail::Version.where(item_type: TRACKED_TYPES).order(created_at: :desc, id: :desc).limit(limit)
    end

    # The version written just before this one for the same record, if any.
    def previous(version)
      PaperTrail::Version
        .where(item_type: version.item_type, item_id: version.item_id)
        .where("(created_at, id) < (?, ?)", version.created_at, version.id)
        .order(created_at: :desc, id: :desc)
        .first
    end

    # What a version changed, as human-readable lines. A caller listing a card's versions in order
    # already holds the previous snapshot and can pass it, saving a query per row.
    def changes(version, previous_snapshot: :lookup)
      case version.event
      when "baseline" then [ "Card before its first recorded change" ]
      when "create" then [ "Created" ]
      else
        if version.item_type == "Catalog::Profile"
          previous_snapshot = previous(version)&.card_snapshot if previous_snapshot == :lookup
          CardSnapshot.diff(previous_snapshot, version.card_snapshot)
        else
          field_changes(version)
        end
      end
    end

    # Of these versions, the ids that are their card's latest — the card's current state, which
    # there is nothing to restore to. One query, whatever the number of cards.
    def current_card_version_ids(versions)
      card_ids = versions.select { |v| v.item_type == "Catalog::Profile" }.map(&:item_id).uniq
      return Set.new if card_ids.empty?

      PaperTrail::Version.where(item_type: "Catalog::Profile", item_id: card_ids)
        .select("DISTINCT ON (item_id) id").order(:item_id, created_at: :desc, id: :desc)
        .map(&:id).to_set
    end

    # Only a version that holds a full state can be restored: a card snapshot, or a weapon/rule
    # version paper_trail can reify (its state before that change).
    def revertable?(version)
      if version.item_type == "Catalog::Profile"
        version.card_snapshot.present?
      else
        version.event != "create"
      end
    end

    # The authors of these versions, keyed by whodunnit (a user id, as a string).
    def authors(versions)
      ids = versions.map(&:whodunnit).compact.uniq
      User.where(id: ids).to_h { |user| [ user.id.to_s, user.username.presence || user.email ] }
    end

    def field_changes(version)
      return [ "Deleted" ] if version.event == "destroy"

      (version.object_changes || {}).except(*HIDDEN_CHANGES).map do |field, (old, new)|
        "#{field.humanize}: #{CardSnapshot.display(old)} → #{CardSnapshot.display(new)}"
      end
    end

    def write!(profile, event:, snapshot:, whodunnit:, reverted_from_id: nil)
      PaperTrail::Version.create!(
        item_type: profile.class.base_class.name, item_id: profile.id, event: event,
        whodunnit: whodunnit, card_snapshot: snapshot, reverted_from_id: reverted_from_id
      )
    end
  end
end
