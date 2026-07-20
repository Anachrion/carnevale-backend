# CARNEVALEB-23: the Emissary of Mother Hydra automatically brings its four Tentacles into the gang
# (1 of each, or 2 of each once its +12-Ducat upgrade is bought), and the Tentacles themselves can
# never be hired or summoned on their own. These facts aren't part of the catalog YAML round-trip
# (like flexible_leader), so they're asserted here instead — the same idempotent, re-runnable pattern
# as leaders:configure_exceptions. Run once after `rails db:seed` (or against existing production).
namespace :companions do
  # parent name => { ducats: upgrade cost, companions: { companion name => [base, upgraded] } }
  AUTO_INCLUSIONS = {
    "Emissary of Mother Hydra" => {
      ducats: 12,
      companions: {
        "Maw Tentacle"    => [ 1, 2 ],
        "Lash Tentacle"   => [ 1, 2 ],
        "Dagger Tentacle" => [ 1, 2 ],
        "Thorn Tentacle"  => [ 1, 2 ]
      }
    }
  }.freeze

  # Every profile that can only ever arrive as another model's companion — hidden from the hire
  # search and the summon picker, and rejected by the hire/summon endpoints.
  NON_RECRUITABLE = [ "Dagger Tentacle", "Lash Tentacle", "Maw Tentacle", "Thorn Tentacle" ].freeze

  desc "Flag non-recruitable models and wire up auto-included companions (CARNEVALEB-23)"
  task configure_exceptions: :environment do
    NON_RECRUITABLE.each do |name|
      profile = Catalog::Profile.find_by(name: name)
      unless profile
        warn "  ! #{name} not found — skipping"
        next
      end
      profile.update!(recruitable: false)
      puts "  ✓ #{name} flagged non-recruitable"
    end

    AUTO_INCLUSIONS.each do |parent_name, config|
      parent = Catalog::Profile.find_by(name: parent_name)
      unless parent
        warn "  ! #{parent_name} not found — skipping"
        next
      end
      parent.update!(companion_upgrade_ducats: config[:ducats])

      config[:companions].each do |companion_name, (base, upgraded)|
        companion = Catalog::Profile.find_by(name: companion_name)
        unless companion
          warn "  ! #{companion_name} not found — skipping"
          next
        end
        record = Catalog::ProfileCompanion.find_or_initialize_by(profile: parent, companion_profile: companion)
        record.update!(base_quantity: base, upgraded_quantity: upgraded)
      end
      puts "  ✓ #{parent_name} brings #{config[:companions].size} companion(s), upgrade #{config[:ducats]} Ducats"
    end
  end
end
