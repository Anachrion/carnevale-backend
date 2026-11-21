# SPDX-License-Identifier: AGPL-3.0-or-later

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
