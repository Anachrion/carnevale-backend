# Violent Transformation pairs move from Gang::Entry::TRANSFORM_PAIRS into the catalog, so a
# moderator can declare one from the backoffice (CARNEVALEB-85). Stored once, on the form that is
# hired (Yune Lobravym -> The Beast Within), and read both ways. Unique: a profile is the other
# form of at most one model.
class AddTransformsIntoToProfiles < ActiveRecord::Migration[8.1]
  def up
    add_reference :profiles, :transforms_into, foreign_key: { to_table: :profiles }, index: { unique: true }

    # The one pair the constant held, matched by card identifier as the constant did. A no-op on a
    # database without these cards (a fresh test database).
    execute <<~SQL
      UPDATE profiles SET transforms_into_id = beast.profile_id
      FROM card_references yune, card_references beast
      WHERE yune.identifier = 'strigoi-yune-lobravym'
        AND beast.identifier = 'strigoi-the-beast-within'
        AND profiles.id = yune.profile_id
    SQL
  end

  def down
    remove_reference :profiles, :transforms_into, foreign_key: { to_table: :profiles }
  end
end
