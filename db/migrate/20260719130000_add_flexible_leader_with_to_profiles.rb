class AddFlexibleLeaderWithToProfiles < ActiveRecord::Migration[8.1]
  # Some flex Leaders demote only alongside a *specific* Leader rather than any Leader: La Signora
  # drops her Leader keyword only when Il Capitano is in the gang (she's his Companion). This nullable
  # self-reference names that partner; nil means "demotes alongside any Leader" (The Duke, Prince of
  # Thieves, Sopracomito) or "not a flex Leader at all".
  #
  # Nullable and additive, so existing profiles need no backfill — only La Signora is linked, inline
  # here (against production data) and via lib/tasks/leader_exceptions.rake for fresh imports.
  def up
    add_reference :profiles, :flexible_leader_with, null: true,
                                                     foreign_key: { to_table: :profiles }

    say_with_time "Linking La Signora's flexible demotion to Il Capitano" do
      execute(<<~SQL)
        UPDATE profiles AS signora
        SET flexible_leader_with_id = capitano.id
        FROM profiles AS capitano
        WHERE signora.name = 'La Signora' AND capitano.name = 'Il Capitano'
      SQL
    end
  end

  def down
    remove_reference :profiles, :flexible_leader_with, foreign_key: { to_table: :profiles }
  end
end
