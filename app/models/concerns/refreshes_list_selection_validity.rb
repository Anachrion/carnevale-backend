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

# Recomputes a Gang::List's cached selection validity after any change to a record that can affect
# it (an entry or one of its spells). Each including model reaches the list differently, so it
# supplies `#selection_validity_list`; the after_commit + refresh call itself lives here once
# instead of being copy-pasted onto each model.
module RefreshesListSelectionValidity
  extend ActiveSupport::Concern

  included do
    after_commit :refresh_list_selection_validity, on: %i[create update destroy]
  end

  private

  def refresh_list_selection_validity
    selection_validity_list&.refresh_selection_validity
  end
end
