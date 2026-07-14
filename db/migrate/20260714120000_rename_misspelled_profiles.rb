class RenameMisspelledProfiles < ActiveRecord::Migration[8.1]
  # Two profiles were seeded with misspelled names; the seed files (db/seeds/rashaar.rb,
  # db/seeds/strigoi.rb) now use the corrected spelling. Rename the existing rows so an
  # already-seeded database matches the seeds — without this, the next seed run's
  # find_or_create_by!(name:) would not find them and would create duplicate profiles.
  #
  # The card_reference `identifier` slug is intentionally left unchanged (it is an opaque,
  # externally-referenced key); only the human-readable `name` is corrected. Illustrations
  # link by profile_id, so they are unaffected. Idempotent: only rows still holding the old
  # name/spelling are touched, so re-running (or running post-reseed) is a no-op.
  RENAMES = [
    # faction,   old name,             new name,             card_reference identifier
    [ "rashaar", "Bounding Telebine", "Bounding Telchine", "rashaar-bounding-telebine" ],
    [ "strigoi", "Cetean Upior",      "Cetean Upiór",      "strigoi-cetean-upior" ]
  ].freeze

  def up
    RENAMES.each { |faction, old_name, new_name, identifier| rename(faction, old_name, new_name, identifier) }
  end

  def down
    RENAMES.each { |faction, old_name, new_name, identifier| rename(faction, new_name, old_name, identifier) }
  end

  private

  def rename(faction, from, to, identifier)
    execute(<<~SQL)
      UPDATE profiles SET name = #{connection.quote(to)}, updated_at = now()
      WHERE faction = #{connection.quote(faction)} AND name = #{connection.quote(from)}
    SQL
    execute(<<~SQL)
      UPDATE card_references SET name = #{connection.quote(to)}, updated_at = now()
      WHERE identifier = #{connection.quote(identifier)} AND name = #{connection.quote(from)}
    SQL
  end
end
