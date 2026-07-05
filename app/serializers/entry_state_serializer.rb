class EntryStateSerializer
  def initialize(entry_state)
    @entry_state = entry_state
  end

  def as_json
    s = @entry_state
    {
      life_points: { current: s.current_life_points, starting: s.starting_life_points },
      will_points: { current: s.current_will_points, starting: s.starting_will_points },
      command_points: { current: s.current_command_points, starting: s.starting_command_points },
      stunned: s.stunned?,
      hidden: s.hidden?,
      guarding: s.guarding?,
      carrying_objective: s.carrying_objective?,
      underwater_counters: s.underwater_counters
    }
  end
end
