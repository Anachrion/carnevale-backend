module Encounter
  class EntryState < ApplicationRecord
    BOOLEAN_COUNTERS = %w[stunned hidden guarding carrying_objective].freeze
    COUNTER_KEYS = (BOOLEAN_COUNTERS + %w[underwater_counters activated_on_turn]).freeze
    # What a client is allowed to send. `activated_on_turn` is server-written and deliberately absent:
    # a client sends the virtual boolean `activated`, which the controller stamps with that player's
    # own turn cursor, so nobody can forge an activation on a turn they aren't on.
    CLIENT_COUNTER_KEYS = (BOOLEAN_COUNTERS + %w[underwater_counters activated]).freeze
    DEFAULT_COUNTERS = {
      "stunned" => false,
      "hidden" => false,
      "guarding" => false,
      "carrying_objective" => false,
      "underwater_counters" => 0,
      "activated_on_turn" => nil
    }.freeze

    belongs_to :list_entry, class_name: "Gang::Entry"

    validates :list_entry_id, uniqueness: true
    validates :current_life_points, :starting_life_points,
              :current_will_points, :starting_will_points,
              :current_command_points, :starting_command_points,
              presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate :counters_shape
    validate :spell_casts_shape

    # Snapshots the entry's profile stats as both current and starting values, and resets every
    # counter to its default — called once per model when a game starts (Encounter::Game#start!).
    def self.create_for!(list_entry)
      profile = list_entry.entry.profile
      create!(
        list_entry: list_entry,
        current_life_points: profile.life_points, starting_life_points: profile.life_points,
        current_will_points: profile.will_points, starting_will_points: profile.will_points,
        current_command_points: profile.command_points, starting_command_points: profile.command_points,
        counters: DEFAULT_COUNTERS.dup
      )
    end

    BOOLEAN_COUNTERS.each do |flag|
      define_method("#{flag}?") { counters[flag] }
    end

    def underwater_counters
      counters["underwater_counters"]
    end

    # Activation is stored as the turn the model activated on rather than a plain boolean, because
    # `current_turn` is a per-player *rewindable* cursor (Encounter::Player#advance_turn!/#rewind_turn!),
    # not a monotonic game clock. Stamping the turn makes the per-turn reset implicit — on a fresh turn
    # nothing matches, so the whole gang reads as un-activated without a bulk write — and rewinding to
    # an earlier turn restores exactly the activations that turn had, which a boolean cleared on every
    # turn change would have destroyed.
    def activated?(turn)
      turn.present? && counters["activated_on_turn"] == turn
    end

    def set_activated(flag, turn:)
      self.counters = counters.merge("activated_on_turn" => (flag ? turn : nil))
    end

    # A model is dead when it has lost its last life point. Derived rather than stored: HP is already
    # tracked and clamped at 0, so a separate `killed` flag would only introduce a second source of
    # truth that could contradict it (killed at full HP, alive at 0). Killing a model is therefore
    # just setting its HP to 0 through the existing stats endpoint — no new state, no new action.
    def dead?
      current_life_points.zero?
    end

    # Whether a known/granted spell (identified by `key`, e.g. "spell:42" or "granted:7") reads as
    # already cast. For a `resets_each_round: true` pool/grant (the default — "each character may
    # only attempt to cast each spell once per round") it's cast only if the stored turn matches the
    # current one, mirroring `activated?` above: a fresh round makes it read as available again with
    # no bulk-reset write, and rewinding a round restores exactly that round's state. For
    # `resets_each_round: false` (Adventuring Noble's pool: "once per game") any stored value at all
    # means permanently exhausted, regardless of which turn it was cast on.
    def spell_cast?(key, resets_each_round:, current_turn:)
      stored = spell_casts[key]
      return false if stored.nil?

      resets_each_round ? stored == current_turn : true
    end

    # Marks (or unmarks) a spell cast for the given turn. Unmarking works the same for a
    # `resets_each_round: false` spell as for any other — Adventuring Noble's spells don't reset on
    # their own each round, but the player can always correct a misclick by hand.
    def set_spell_cast(key, cast:, turn:)
      self.spell_casts = cast ? spell_casts.merge(key => turn) : spell_casts.except(key)
    end

    private

    def counters_shape
      return errors.add(:counters, "must be an object") unless counters.is_a?(Hash)
      return errors.add(:counters, "must only contain #{COUNTER_KEYS.join(', ')}") unless (counters.keys - COUNTER_KEYS).empty?

      BOOLEAN_COUNTERS.each do |key|
        errors.add(:counters, "#{key} must be true or false") unless [ true, false ].include?(counters[key])
      end

      errors.add(:counters, "underwater_counters must be 0, 1, or 2") unless (0..2).cover?(counters["underwater_counters"])

      # Absent (rather than explicitly null) on states created before activation tracking existed —
      # those read as never-activated, so an in-flight game needs no backfill.
      activated_on_turn = counters["activated_on_turn"]
      unless activated_on_turn.nil? || (activated_on_turn.is_a?(Integer) && activated_on_turn.positive?)
        errors.add(:counters, "activated_on_turn must be a positive integer or null")
      end
    end

    # Keys are "spell:<id>"/"granted:<id>" identities, values are the turn (a positive integer) the
    # spell was cast on — see #spell_cast?.
    def spell_casts_shape
      return errors.add(:spell_casts, "must be an object") unless spell_casts.is_a?(Hash)

      spell_casts.each do |key, turn|
        unless key.is_a?(String) && key.match?(/\A(spell|granted):\d+\z/)
          errors.add(:spell_casts, "key #{key.inspect} must be shaped like \"spell:<id>\" or \"granted:<id>\"")
        end
        errors.add(:spell_casts, "turn for #{key.inspect} must be a positive integer") unless turn.is_a?(Integer) && turn.positive?
      end
    end
  end
end

# == Schema Information
#
# Table name: entry_states
#
#  id                      :bigint           not null, primary key
#  counters                :json             not null
#  current_command_points  :integer          not null
#  current_life_points     :integer          not null
#  current_will_points     :integer          not null
#  spell_casts             :json             not null
#  starting_command_points :integer          not null
#  starting_life_points    :integer          not null
#  starting_will_points    :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  list_entry_id           :bigint           not null
#
# Indexes
#
#  index_entry_states_on_list_entry_id  (list_entry_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_entry_id => list_entries.id)
#
