class AddRecruitableAndCompanionUpgradeToProfiles < ActiveRecord::Migration[8.1]
  # CARNEVALEB-23: some models can never be hired or summoned directly — they only ever reach the
  # board automatically, brought in by another model (the Emissary of Mother Hydra's four Tentacles).
  # `recruitable: false` hides them from the hire search and the summon picker, and the hire/summon
  # endpoints reject them outright.
  #
  # A profile that brings companions may also offer an optional paid upgrade
  # (`companion_upgrade_ducats > 0`): the Emissary takes 1 of each Tentacle for free, or 2 of each
  # for +12 Ducats. 0 means "no upgrade available".
  NON_RECRUITABLE = [ "Dagger Tentacle", "Lash Tentacle", "Maw Tentacle", "Thorn Tentacle" ].freeze
  UPGRADE_DUCATS = { "Emissary of Mother Hydra" => 12 }.freeze

  def up
    add_column :profiles, :recruitable, :boolean, null: false, default: true
    add_column :profiles, :companion_upgrade_ducats, :integer, null: false, default: 0

    # Flag the exception profiles against existing production data inline, so a deploy needs no
    # follow-up command (mirroring AddFlexibleLeaderToProfiles). A fresh install has no profiles yet
    # at migration time — there db/seeds.rb's companions:configure_exceptions handles it instead.
    say_with_time "Flagging #{NON_RECRUITABLE.size} non-recruitable profiles" do
      quoted = NON_RECRUITABLE.map { |name| connection.quote(name) }.join(", ")
      execute("UPDATE profiles SET recruitable = FALSE WHERE name IN (#{quoted})")
    end

    UPGRADE_DUCATS.each do |name, ducats|
      execute("UPDATE profiles SET companion_upgrade_ducats = #{ducats.to_i} WHERE name = #{connection.quote(name)}")
    end
  end

  def down
    remove_column :profiles, :companion_upgrade_ducats
    remove_column :profiles, :recruitable
  end
end
