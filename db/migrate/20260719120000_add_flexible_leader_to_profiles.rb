class AddFlexibleLeaderToProfiles < ActiveRecord::Migration[8.1]
  # "Flex leaders": profiles printed with both the Leader and Hero keywords whose special rule demotes
  # them to a plain Hero when the gang already contains another Leader ("if there is another character
  # with the Leader keyword, this character loses the Leader keyword"). They may therefore be hired
  # alongside an existing Leader. The client reads this to keep showing their "add" button once a
  # Leader is in the list, and ListValidationService#check_leader_count honours the demotion.
  #
  # Named inline (not via lib/tasks/leader_exceptions.rake) so this migration stays a self-contained,
  # point-in-time record — the same reason data migrations don't reach into app models.
  FLEXIBLE_LEADERS = [ "The Duke", "Prince of Thieves", "Sopracomito", "La Signora" ].freeze

  def up
    add_column :profiles, :flexible_leader, :boolean, null: false, default: false

    # Flag the exception profiles against existing production data right here, so a deploy needs no
    # follow-up command. A fresh install has no profiles yet at migration time (the catalog snapshot
    # is imported afterward) — there db/seeds.rb's leaders:configure_exceptions handles it instead.
    say_with_time "Flagging #{FLEXIBLE_LEADERS.size} flexible-leader profiles" do
      quoted = FLEXIBLE_LEADERS.map { |name| connection.quote(name) }.join(", ")
      execute("UPDATE profiles SET flexible_leader = TRUE WHERE name IN (#{quoted})")
    end
  end

  def down
    remove_column :profiles, :flexible_leader
  end
end
