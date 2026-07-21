class DropInvalidFactionDefaultFromProfiles < ActiveRecord::Migration[8.1]
  # profiles.faction was created with default: "" (see create_profiles), but "" is not a member of
  # the faction enum (HasFaction::FACTIONS), so the default could only ever seed an invalid value.
  # faction is always set explicitly by the catalog import and the column stays NOT NULL, so drop
  # the default — matching gang_lists.faction, which never had one.
  def change
    change_column_default :profiles, :faction, from: "", to: nil
  end
end
