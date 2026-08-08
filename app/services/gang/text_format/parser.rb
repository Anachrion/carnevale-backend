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
  class TextFormat
    # Reads the text back into a plain structure. Deliberately knows nothing about the catalog or
    # the database: it reports what the text *says*, and Gang::TextImport decides what exists.
    # Keeping the two apart is what lets the round-trip test compare texts without touching records.
    #
    # Line-oriented rather than one big regular expression, because this format is meant to be
    # hand-edited: a reader can see exactly which line was rejected and why.
    class Parser
      Result = Struct.new(:name, :faction, :points, :models, :equipment, :warnings, keyword_init: true)
      Model = Struct.new(:name, :mentor, :upgrade, :pools, keyword_init: true)
      PoolSelection = Struct.new(:label, :disciplines, :spells, keyword_init: true)

      def initialize(text)
        @lines = text.to_s.split("\n")
        @warnings = []
      end

      def parse
        result = Result.new(name: nil, faction: nil, points: nil, models: [], equipment: [], warnings: @warnings)
        section = nil

        @lines.each_with_index do |raw, index|
          line = raw.rstrip
          next if line.strip.empty?

          case line.strip
          when MODELS_SECTION then section = :models
          when EQUIPMENT_SECTION then section = :equipment
          else
            # An indented line belongs to the model above it; anything else is either a header pair
            # (before the first section) or a new entry.
            if line.start_with?("- ")
              add_entry(result, section, line.delete_prefix("- ").strip, index)
            elsif line.start_with?(" ", "\t")
              add_attribute(result, section, line.strip, index)
            else
              read_header(result, line, index)
            end
          end
        end

        result
      end

      private

      def read_header(result, line, index)
        key, value = split_pair(line)
        return warn_at(index, line, "expected 'Key: value'") if key.nil?

        case key
        when HEADER_KEY then result.name = value
        when FACTION_KEY then result.faction = value.downcase
        when DUCATS_KEY then result.points = (Integer(value, exception: false) || warn_ducats(index, value))
        else warn_at(index, line, "unknown header '#{key}'")
        end
      end

      def add_entry(result, section, name, index)
        return warn_at(index, name, "entry outside any section") if section.nil?
        return warn_at(index, name, "unnamed entry") if name.empty?

        if section == :equipment
          result.equipment << name
        else
          result.models << Model.new(name: name, mentor: nil, upgrade: false, pools: [])
        end
      end

      def add_attribute(result, section, line, index)
        model = result.models.last
        # Equipment carries no attributes, and an attribute before any model has nothing to attach to.
        return warn_at(index, line, "no model to attach this to") if model.nil? || section != :models

        return model.upgrade = true if line.casecmp(UPGRADE_KEY).zero?

        key, value = split_pair(line)
        return warn_at(index, line, "expected 'Key: value'") if key.nil?

        if key.casecmp(MENTOR_KEY).zero?
          model.mentor = value
        else
          model.pools << pool_selection(key, value)
        end
      end

      # `Discipline: A, B > Spell One, Spell Two` — everything before the separator names the chosen
      # Disciplines, everything after names the spells picked under them. A pool that grants only a
      # cantrip (Tarot Reader's Minor Arcana) has no separator and no spells: the Discipline is the
      # whole selection.
      def pool_selection(label, value)
        disciplines_part, spells_part = value.split(SPELL_SEPARATOR, 2)
        PoolSelection.new(
          label: label,
          disciplines: split_list(disciplines_part),
          spells: split_list(spells_part)
        )
      end

      def split_list(text)
        text.to_s.split(",").map(&:strip).reject(&:empty?)
      end

      def split_pair(line)
        key, value = line.split(":", 2)
        return [ nil, nil ] if value.nil?

        [ key.strip, value.strip ]
      end

      def warn_ducats(index, value)
        warn_at(index, value, "Ducats must be a whole number")
        nil
      end

      def warn_at(index, text, reason)
        @warnings << "line #{index + 1}: #{reason} (#{text.strip})"
        nil
      end
    end
  end
end
