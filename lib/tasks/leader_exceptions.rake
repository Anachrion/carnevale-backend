# CARNEVALEB-49: the Leader profiles that may be hired alongside another Leader. Each prints with
# both the Leader and Hero keywords and a special rule that drops its Leader keyword (demoting it to
# a plain Hero) whenever the gang already contains another Leader — so the client keeps offering them
# once a Leader is present, and ListValidationService#check_leader_count treats them as demotable.
# Idempotent: re-running just re-asserts the same flag. Run once after `rails db:seed` (or against
# existing production data), the same way spell_pools:configure_exceptions is.
namespace :leaders do
  desc "Flag the Leader profiles that demote to a Hero alongside another Leader (flexible_leader)"
  task configure_exceptions: :environment do
    FLEXIBLE_LEADERS = [
      "The Duke",         # Inspiring Hero
      "Prince of Thieves", # A Hero Among Thieves
      "Sopracomito",      # Second in Command
      "La Signora"        # Cheat (demotes specifically alongside Il Capitano)
    ].freeze

    FLEXIBLE_LEADERS.each do |name|
      profile = Catalog::Profile.find_by(name: name)
      unless profile
        warn "  ! #{name} not found — skipping"
        next
      end
      profile.update!(flexible_leader: true)
      puts "  ✓ #{name} flagged flexible_leader"
    end

    # La Signora is a conditional flex Leader: she demotes only alongside Il Capitano, not any Leader.
    signora = Catalog::Profile.find_by(name: "La Signora")
    capitano = Catalog::Profile.find_by(name: "Il Capitano")
    if signora && capitano
      signora.update!(flexible_leader_with: capitano)
      puts "  ✓ La Signora demotes only alongside Il Capitano"
    end

    puts "Flagged #{FLEXIBLE_LEADERS.size} flexible-leader profiles."
  end
end
