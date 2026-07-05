module Encounter
  class EntryState < ApplicationRecord
    BOOLEAN_COUNTERS = %w[stunned hidden guarding carrying_objective].freeze
    COUNTER_KEYS = (BOOLEAN_COUNTERS + %w[underwater_counters]).freeze
    DEFAULT_COUNTERS = {
      "stunned" => false,
      "hidden" => false,
      "guarding" => false,
      "carrying_objective" => false,
      "underwater_counters" => 0
    }.freeze

    belongs_to :list_entry, class_name: "Gang::Entry"

    validates :list_entry_id, uniqueness: true
    validates :current_life_points, :starting_life_points,
              :current_will_points, :starting_will_points,
              :current_command_points, :starting_command_points,
              presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validate :counters_shape

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

    private

    def counters_shape
      return errors.add(:counters, "must be an object") unless counters.is_a?(Hash)
      return errors.add(:counters, "must only contain #{COUNTER_KEYS.join(', ')}") unless (counters.keys - COUNTER_KEYS).empty?

      BOOLEAN_COUNTERS.each do |key|
        errors.add(:counters, "#{key} must be true or false") unless [ true, false ].include?(counters[key])
      end

      errors.add(:counters, "underwater_counters must be 0, 1, or 2") unless (0..2).cover?(counters["underwater_counters"])
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
