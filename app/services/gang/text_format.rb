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

module Gang
  # The plain-text exchange format for a gang (CARNEVALEB-74): what `dump` writes is exactly what
  # `parse` reads back, so a gang survives a trip through a chat message, a printed sheet or a QR
  # code. Both directions live here on purpose — split across two languages they would drift.
  #
  #   Carnevale gang: Blood of the Lamb
  #   Faction: guild
  #   Ducats: 150
  #
  #   Models
  #   - Doctor of the Firmament
  #     Disciplines: Blood Rites, Fateweaving > Whispered Fate, Threadbare
  #   - Seamstress
  #     Discipline: Divinity > Radiant Mend
  #     Entwined Magics: Fateweaving > Threadbare
  #   - Apprentice Doctor
  #     Mentor: Doctor of the Firmament
  #     Discipline: Blood Rites > Sanguine Ward
  #   - Emissary of Mother Hydra
  #     Upgrade
  #
  #   Equipment
  #   - Climbing Tools
  #
  # Models are named, never numbered: two copies of a profile can hold different spells, so each
  # gets its own block. Illustrations are deliberately absent — a gang list is what you took, not
  # which artwork you picked, and dropping them is what keeps this readable and QR-sized.
  #
  # == How a spell selection binds to a pool
  #
  # The line's *label* is the binding, not its position. A profile's first spell pool is written
  # `Discipline:` (or `Disciplines:` when it picks more than one); any further pool is written under
  # the name of the special rule that grants it. That matters because the two profiles with two
  # pools — Seamstress and Tarot Reader — have pools with *identical* eligible disciplines, so
  # nothing in the selection itself could tell them apart:
  #
  #   * Seamstress [Entwined Magics] — a second spell from any accessible Discipline, and
  #     explicitly no extra cantrip if it differs. Its pool has grants_cantrip false.
  #   * Tarot Reader [Minor Arcana] — one extra cantrip from a *different* Discipline. Its pool has
  #     no spell slots at all, so the chosen Discipline alone *is* the cantrip.
  #
  # Binding by label also means a pool with nothing chosen simply writes no line, and a hand-edited
  # file that drops or reorders lines still reads correctly.
  class TextFormat
    HEADER_KEY = "Carnevale gang".freeze
    FACTION_KEY = "Faction".freeze
    DUCATS_KEY = "Ducats".freeze
    MODELS_SECTION = "Models".freeze
    EQUIPMENT_SECTION = "Equipment".freeze
    MENTOR_KEY = "Mentor".freeze
    UPGRADE_KEY = "Upgrade".freeze
    # The label for a profile's first pool. Plural when that pool picks more than one Discipline —
    # Doctor of the Firmament's Aetheric Gaze is the only one today.
    FIRST_POOL_LABELS = [ "Discipline", "Disciplines" ].freeze
    # Splits the chosen Disciplines from the spells picked under them.
    SPELL_SEPARATOR = ">".freeze

    # Spelled out rather than derived: `titleize` would write "Runes Of Sovereignty".
    DISCIPLINE_LABELS = {
      "blood_rites" => "Blood Rites",
      "divinity" => "Divinity",
      "fateweaving" => "Fateweaving",
      "runes_of_sovereignty" => "Runes of Sovereignty",
      "wild_magic" => "Wild Magic"
    }.freeze

    class << self
      def dump(list)
        new(list).dump
      end

      def parse(text)
        Parser.new(text).parse
      end

      # Loose on the way in, exact on the way out: accepts the label, the stored slug, and anything
      # in between ("Runes of Sovereignty", "runes_of_sovereignty", "RunesOfSovereignty"), so a
      # hand-typed list is not rejected over punctuation.
      def discipline_from(text)
        key = normalize(text)
        DISCIPLINE_LABELS.keys.find { |slug| normalize(slug) == key }
      end

      def normalize(text)
        text.to_s.downcase.gsub(/[^a-z0-9]/, "")
      end
    end

    def initialize(list)
      @list = list
    end

    def dump
      lines = [
        "#{HEADER_KEY}: #{@list.name}",
        "#{FACTION_KEY}: #{@list.faction}",
        "#{DUCATS_KEY}: #{@list.points}"
      ]
      models, equipment = exportable_entries.partition { |e| e.entry.is_a?(Catalog::CardReference) }

      if models.any?
        lines << "" << MODELS_SECTION
        models.each { |entry| lines.concat(model_lines(entry)) }
      end
      if equipment.any?
        lines << "" << EQUIPMENT_SECTION
        equipment.each { |entry| lines << "- #{entry.entry.name}" }
      end
      "#{lines.join("\n")}\n"
    end

    private

    # Companions are auto-included by CompanionSyncService when their parent is hired, and summoned
    # models were conjured mid-game rather than bought — neither is a choice anyone made, and both
    # come back on their own, so writing them down would only risk duplicating them on the way in.
    def exportable_entries
      @list.list_entries.reject { |e| e.companion_of_entry_id.present? || e.summoned? }
           .sort_by(&:position)
    end

    def model_lines(entry)
      lines = [ "- #{entry.profile&.name || entry.entry.name}" ]
      lines << "  #{MENTOR_KEY}: #{entry.mentored_by_entry.profile.name}" if entry.mentored_by_entry&.profile
      lines << "  #{UPGRADE_KEY}" if entry.upgrade_selected?
      lines.concat(pool_lines(entry))
      lines
    end

    def pool_lines(entry)
      pools = entry.profile&.profile_spell_pools&.sort_by { |p| [ p.position.to_i, p.id ] } || []
      pools.filter_map.with_index do |pool, index|
        # Adventuring Noble's Arcane Totem: it knows every spell of its one Discipline outright, so
        # nothing was ever picked and there is nothing here to restore.
        next if pool.unlimited?

        disciplines = entry.entry_pool_disciplines.select { |d| d.pool_id == pool.id }.map(&:discipline)
        spells = entry.entry_spells.select { |s| s.pool_id == pool.id }.map(&:spell).compact
        next if disciplines.empty? && spells.empty?

        value = disciplines.map { |d| DISCIPLINE_LABELS.fetch(d, d) }.join(", ")
        value += " #{SPELL_SEPARATOR} #{spells.map(&:name).join(', ')}" if spells.any?
        "  #{pool_label(pool, index)}: #{value}"
      end
    end

    def pool_label(pool, index)
      return pool.special_rule.name if index.positive? && pool.special_rule

      pool.of.to_i > 1 ? FIRST_POOL_LABELS.last : FIRST_POOL_LABELS.first
    end
  end
end
