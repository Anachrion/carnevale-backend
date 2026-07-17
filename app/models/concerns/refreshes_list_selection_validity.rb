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
