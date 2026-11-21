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

module Catalog
  # A whole card, as one plain hash: the profile's own columns plus everything hanging off it —
  # weapons, special rules, spell pools, granted spells, companions — in print order.
  #
  # This is what the catalog history (CARNEVALEB-81) stores per version. A card is versioned as one
  # document rather than row by row because Profile#replace_*! destroys and recreates its join and
  # child rows on every save: tracked per row, an edit that removes one weapon would read as N
  # deletions and N creations, with new ids each time. Compared as snapshots, it reads as
  # "Weapon removed: Stiletto".
  #
  # Keys are strings throughout, so a snapshot read back from the jsonb column compares equal to a
  # freshly captured one.
  module CardSnapshot
    SKIPPED_COLUMNS = %w[id profile_id pool_id position created_at updated_at].freeze

    # Display-only keys, carried for a readable history but never written back by restore!.
    LABEL = "label"

    module_function

    def capture(profile)
      profile = Profile.includes(
        { profile_weapons: :weapon }, { profile_special_rules: :special_rule },
        { profile_spell_pools: %i[profile_spell_pool_disciplines special_rule] },
        { profile_granted_spells: %i[spell special_rule] },
        { profile_companions: :companion_profile }, :card_references
      ).find(profile.id)

      {
        "attributes" => profile.attributes.except("id", "created_at", "updated_at"),
        "weapons" => profile.profile_weapons.sort_by(&:position).map { |pw| { "id" => pw.weapon_id, "name" => pw.weapon.name } },
        "special_rules" => profile.profile_special_rules.sort_by(&:position).map { |pr| { "id" => pr.special_rule_id, "name" => pr.special_rule.name } },
        "spell_pools" => profile.profile_spell_pools.sort_by(&:position).map do |pool|
          columns(pool).merge("disciplines" => pool.disciplines.sort, LABEL => pool.special_rule&.name)
        end,
        "granted_spells" => profile.profile_granted_spells.sort_by(&:position).map do |grant|
          columns(grant).merge(LABEL => grant.resolved_name || grant.grant_kind.humanize)
        end,
        "companions" => profile.profile_companions.sort_by(&:companion_profile_id).map do |pc|
          columns(pc).merge(LABEL => pc.companion_profile.name)
        end,
        "card_references" => profile.card_references.map(&:identifier).sort
      }
    end

    # Writes a snapshot back onto the profile through the same paths the editor uses, so a restored
    # card is exactly as valid as an edited one. Weapons and rules deleted since the snapshot was
    # taken are skipped; their names are returned so the caller can say so. Must run inside a
    # transaction: a pool or grant that no longer validates raises RecordInvalid.
    def restore!(profile, snapshot)
      skipped = []

      profile.assign_attributes(snapshot.fetch("attributes").slice(*Profile.column_names))
      profile.save!

      { "weapons" => [ Weapon, :replace_weapons! ], "special_rules" => [ SpecialRule, :replace_special_rules! ] }
        .each do |key, (klass, writer)|
          rows = snapshot.fetch(key, [])
          existing = klass.where(id: rows.map { |r| r["id"] }).pluck(:id).to_set
          skipped.concat(rows.reject { |r| existing.include?(r["id"]) }.map { |r| r["name"] })
          profile.public_send(writer, rows.map { |r| r["id"] }.select { |id| existing.include?(id) })
        end

      profile.replace_spell_pools!(snapshot.fetch("spell_pools", []).map { |row| writable(row).symbolize_keys })
      profile.replace_granted_spells!(snapshot.fetch("granted_spells", []).map { |row| writable(row).symbolize_keys })
      profile.replace_companions!(snapshot.fetch("companions", []).map { |row| writable(row).symbolize_keys })

      skipped
    end

    # Human-readable lines describing what changed from one snapshot to the next.
    def diff(before, after)
      return [] if before.nil? || after.nil?

      lines = attribute_lines(before.fetch("attributes", {}), after.fetch("attributes", {}))
      lines += named_list_lines("Weapon", before["weapons"], after["weapons"])
      lines += named_list_lines("Special rule", before["special_rules"], after["special_rules"])
      lines += row_lines("Spell pool", before["spell_pools"], after["spell_pools"])
      lines += row_lines("Granted spell", before["granted_spells"], after["granted_spells"])
      lines += row_lines("Companion", before["companions"], after["companions"])
      lines
    end

    # ── helpers ───────────────────────────────────────────────────────────────────

    def columns(record)
      record.attributes.except(*SKIPPED_COLUMNS)
    end

    def writable(row)
      row.except(LABEL)
    end

    def attribute_lines(before, after)
      (before.keys | after.keys).filter_map do |key|
        old, new = before[key], after[key]
        next if old == new

        if old.is_a?(Array) || new.is_a?(Array)
          added = Array(new) - Array(old)
          removed = Array(old) - Array(new)
          parts = added.map { |v| "+#{v}" } + removed.map { |v| "−#{v}" }
          "#{key.humanize}: #{parts.any? ? parts.join(", ") : "reordered"}"
        else
          "#{key.humanize}: #{display(old)} → #{display(new)}"
        end
      end
    end

    # Weapons and special rules: membership changes by name, or a plain "reordered".
    def named_list_lines(noun, before, after)
      before = Array(before)
      after = Array(after)
      return [] if before == after

      before_ids = before.map { |r| r["id"] }
      after_ids = after.map { |r| r["id"] }
      removed = before.reject { |r| after_ids.include?(r["id"]) }.map { |r| "#{noun} removed: #{r["name"]}" }
      added = after.reject { |r| before_ids.include?(r["id"]) }.map { |r| "#{noun} added: #{r["name"]}" }
      changes = removed + added
      changes.presence || [ "#{noun}s reordered" ]
    end

    # Owned rows (pools, grants, companions) have no stable id, so they are compared by position.
    def row_lines(noun, before, after)
      before = Array(before)
      after = Array(after)
      return [] if before == after

      [ before.size, after.size ].max.times.flat_map do |i|
        old, new = before[i], after[i]
        name = "#{noun} #{i + 1}"
        if old.nil?
          [ "#{name} added#{label_suffix(new)}" ]
        elsif new.nil?
          [ "#{name} removed#{label_suffix(old)}" ]
        else
          attribute_lines(writable(old), writable(new)).map { |line| "#{name}#{label_suffix(new)}: #{line}" }
        end
      end
    end

    def label_suffix(row)
      row[LABEL].present? ? " (#{row[LABEL]})" : ""
    end

    def display(value)
      return "—" if value.nil? || value == "" || value == []

      value.is_a?(Array) ? value.join(", ") : value.to_s
    end
  end
end
