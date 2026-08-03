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
