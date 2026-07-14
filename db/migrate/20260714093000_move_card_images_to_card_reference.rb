class MoveCardImagesToCardReference < ActiveRecord::Migration[8.1]
  # Card image filenames were stored as strings backfilled from a checked-in copy of the frontend's
  # old profiles.json. They were always derivable, so they are now computed from the identifier —
  # "<identifier>-front.png" / "<identifier>-back.png" (see Catalog::CardReference).
  #
  # A card reference is the finished card the app downloads, so it owns both of its faces. The old
  # scheme named them after the profile, which meant a profile's A/B references shared one front
  # and could never deliver their two different illustrations. illustration_number records which
  # illustration a reference renders with — the link from the authored input (Catalog::Illustration)
  # to the delivered card.
  def up
    add_column :card_references, :illustration_number, :integer, default: 1, null: false

    # Pair each profile's references (ordered by identifier: -a, -b) with its illustrations
    # (ordered by number: 1, 2). Every multi-reference profile has exactly as many illustrations
    # as references, so this is a straight positional zip.
    execute <<~SQL
      UPDATE card_references cr
      SET illustration_number = ranked.illustration_number
      FROM (
        SELECT id,
               ROW_NUMBER() OVER (PARTITION BY profile_id ORDER BY identifier) AS illustration_number
        FROM card_references
      ) ranked
      WHERE cr.id = ranked.id
    SQL

    remove_column :card_references, :card_front, :string
    remove_column :card_references, :card_back, :string
  end

  def down
    add_column :card_references, :card_front, :string
    add_column :card_references, :card_back, :string

    # Restore the pre-migration filenames: both faces named after the profile, so the A/B
    # references of a profile share one front again.
    execute <<~SQL
      UPDATE card_references cr
      SET card_front = slug.base || '-front.png',
          card_back  = slug.base || '-back.png'
      FROM (
        SELECT p.id,
               btrim(
                 regexp_replace(lower(p.faction || '-' || p.name), '[^a-z0-9]+', '-', 'g'),
                 '-'
               ) AS base
        FROM profiles p
      ) slug
      WHERE cr.profile_id = slug.id
    SQL

    remove_column :card_references, :illustration_number
  end
end
