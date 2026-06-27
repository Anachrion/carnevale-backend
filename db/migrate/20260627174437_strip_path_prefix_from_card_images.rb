class StripPathPrefixFromCardImages < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE card_references
      SET card_front = regexp_replace(card_front, '^.+/', ''),
          card_back  = regexp_replace(card_back,  '^.+/', '')
      WHERE card_front IS NOT NULL
    SQL
  end

  def down
    # Irreversible — original paths are not stored
    raise ActiveRecord::IrreversibleMigration
  end
end
