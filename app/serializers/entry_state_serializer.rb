# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class EntryStateSerializer
  # `turn` is the owning player's current turn cursor, needed to derive `activated` — which is stored
  # as the turn the model activated on rather than a boolean (see Encounter::EntryState#activated?).
  # Nil outside a live game, where nothing reads as activated.
  def initialize(entry_state, turn: nil)
    @entry_state = entry_state
    @turn = turn
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
      underwater_counters: s.underwater_counters,
      activated: s.activated?(@turn),
      dead: s.dead?,
      tokens: s.tokens
    }
  end
end
