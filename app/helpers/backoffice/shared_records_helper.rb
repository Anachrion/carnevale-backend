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

module Backoffice
  # Weapons and special rules are shared across the catalog (CARNEVALEB-83).
  module SharedRecordsHelper
    # The form's data attributes: a confirm before saving a record more than one profile carries,
    # since the edit lands on all of their cards at once. Nothing for a new or single-card record.
    def shared_save_confirm(record, noun)
      return {} if record.new_record?

      count = carried_by_profiles(record).count
      return {} if count < 2

      { turbo_confirm: "This #{noun} is on #{count} profiles. Save it and change all of their cards?" }
    end

    # Each profile carrying the record, once. `WHERE id IN (...)` rather than DISTINCT, which
    # Postgres cannot apply to the profiles' json columns.
    def carried_by_profiles(record)
      Catalog::Profile.where(id: record.profiles.select(:id)).order(:name)
    end
  end
end
