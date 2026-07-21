FactoryBot.define do
  factory :entry_state, class: "Encounter::EntryState" do
    association :list_entry
    current_life_points { 10 }
    starting_life_points { 10 }
    current_will_points { 3 }
    starting_will_points { 3 }
    current_command_points { 1 }
    starting_command_points { 1 }
    counters do
      { "stunned" => false, "hidden" => false, "guarding" => false, "carrying_objective" => false, "underwater_counters" => 0, "activated_on_turn" => nil }
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
#  tokens                  :json             not null
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
