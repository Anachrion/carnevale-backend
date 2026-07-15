class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      # Only the SHA-256 digest of the opaque token is stored, never the token itself: a refresh
      # token is long-lived and trades directly for a session, so a leaked database dump must not
      # hand out working credentials the way storing them in the clear would.
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :expires_at
  end
end
