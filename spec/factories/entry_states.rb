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
      { "stunned" => false, "hidden" => false, "guarding" => false, "carrying_objective" => false, "underwater_counters" => 0 }
    end
  end
end
