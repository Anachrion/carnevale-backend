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
  # Rebuilds a gang from the text Gang::TextFormat writes (CARNEVALEB-74). Always creates a *new*
  # list — importing never edits one you already have, so a bad paste costs nothing.
  #
  # == Why three passes
  #
  # Not tidiness; each pass needs the previous one finished.
  #
  #   1. Create the entries. Names are resolved here, and models that bring companions get them
  #      for free (CompanionSyncService), which is why the text never lists companions itself.
  #   2. Wire the mentors. A mentor can be named before it has been created — Apprentice Doctor
  #      may sit above her Doctor in the list — so this cannot happen during pass 1.
  #   3. Apply upgrades and spell selections. Apprentice Doctor's eligible Disciplines *derive from
  #      her mentor*, so her selection is only meaningful once pass 2 has linked it.
  #
  # An unresolvable name is reported and skipped, never fatal: a gang naming one profile this build
  # does not know should still import the rest. Everything else the game cares about — the points
  # limit, roster legality — is left to the usual validation, so an imported gang that breaks a rule
  # arrives flagged exactly as if it had been built by hand.
  class TextImport
    Result = Struct.new(:list, :warnings, keyword_init: true)

    DEFAULT_NAME = "Imported gang".freeze

    def self.call(text, owner:)
      new(text, owner: owner).call
    end

    def initialize(text, owner:)
      @parsed = TextFormat.parse(text)
      @owner = owner
      @warnings = @parsed.warnings.dup
    end

    def call
      list = nil
      # One revalidation at the end rather than one per child callback, matching the spell endpoint.
      Gang::List.defer_validation do
        ActiveRecord::Base.transaction do
          list = build_list
          entries = create_entries(list)
          wire_mentors(entries)
          apply_selections(entries)
        end
      end
      list.refresh_selection_validity
      Result.new(list: list.reload, warnings: @warnings)
    end

    private

    def build_list
      Gang::List.create!(
        owner: @owner,
        name: @parsed.name.presence || DEFAULT_NAME,
        faction: @parsed.faction.presence || Catalog::Profile.new.faction,
        points: @parsed.points || 100
      )
    end

    # Returns the parsed model paired with the record it produced, so the later passes can find an
    # entry again without re-resolving names.
    def create_entries(list)
      pairs = []
      @parsed.models.each do |model|
        profile = find_profile(model.name)
        next warn("unknown model '#{model.name}'") if profile.nil?
        # The Emissary's Tentacles arrive with their parent and cannot be hired on their own; a
        # hand-edited list naming one directly must not conjure it.
        next warn("'#{profile.name}' cannot be hired on its own") if profile.recruitable == false

        reference = profile.card_references.min_by { |r| r.identifier.to_s }
        next warn("'#{profile.name}' has no card to hire") if reference.nil?

        entry = list.list_entries.create!(entry: reference, position: next_position(list))
        CompanionSyncService.call(entry)
        pairs << [ model, entry ]
      end

      @parsed.equipment.each do |name|
        equipment = Catalog::Equipment.find_by("LOWER(name) = ?", name.downcase)
        next warn("unknown equipment '#{name}'") if equipment.nil?

        list.list_entries.create!(entry: equipment, position: next_position(list))
      end
      pairs
    end

    # By name, per the format. Ambiguity is harmless where it can occur: two entries of the same
    # profile expose the same spell pools, so either is the same mentor as far as the rules go.
    def wire_mentors(pairs)
      pairs.each do |model, entry|
        next if model.mentor.blank?

        mentor = pairs.find { |_, candidate| candidate.profile&.name&.casecmp(model.mentor)&.zero? }&.last
        next warn("'#{model.name}' names an unknown mentor '#{model.mentor}'") if mentor.nil?

        entry.update!(mentored_by_entry: mentor)
      end
    end

    def apply_selections(pairs)
      pairs.each do |model, entry|
        # Before the spells: toggling it re-syncs the companion entries, and doing that afterwards
        # would be a second write over a gang we have already finished describing.
        if model.upgrade
          entry.update!(upgrade_selected: true)
          CompanionSyncService.call(entry)
        end
        model.pools.each { |selection| apply_pool(entry, selection) }
      end
    end

    def apply_pool(entry, selection)
      pool = resolve_pool(entry, selection.label)
      return warn("'#{entry.profile&.name}' has no '#{selection.label}' selection to fill") if pool.nil?

      selection.disciplines.each do |name|
        slug = TextFormat.discipline_from(name)
        next warn("unknown Discipline '#{name}'") if slug.nil?

        entry.entry_pool_disciplines.create!(pool_id: pool.id, discipline: slug)
      end

      selection.spells.each do |name|
        spell = Catalog::Spell.find_by("LOWER(name) = ?", name.downcase)
        next warn("unknown spell '#{name}'") if spell.nil?

        entry.entry_spells.create!(pool_id: pool.id, spell: spell)
      end
    end

    # The label is the binding: a profile's first pool is written "Discipline(s)", any other under
    # the name of the special rule that grants it. See Gang::TextFormat for why position alone will
    # not do — Seamstress and Tarot Reader have pools with identical eligible Disciplines.
    def resolve_pool(entry, label)
      pools = entry.profile&.profile_spell_pools&.sort_by { |p| [ p.position.to_i, p.id ] } || []
      return pools.first if TextFormat::FIRST_POOL_LABELS.any? { |l| l.casecmp(label).zero? }

      pools.find { |p| p.special_rule&.name.to_s.casecmp(label).zero? }
    end

    def find_profile(name)
      Catalog::Profile.find_by("LOWER(name) = ?", name.downcase)
    end

    def next_position(list)
      (list.list_entries.maximum(:position) || 0) + 1
    end

    def warn(message)
      @warnings << message
      nil
    end
  end
end
