# Production-only seed data. Loaded from db/seeds.rb only when Rails.env is production.
#
# The single account here is the Google Play review account: Google's reviewers sign in with these
# credentials to examine the app (declared under Play Console → App content → App access, since the
# whole app sits behind a login). It is a plain, NON-admin user with no access to /backoffice.
#
# Its credentials live in Infisical (prod) and reach the container via config/deploy.yml's
# env.secret list — never committed to git, matching the project's no-secrets-in-repo posture.
# Whatever you enter in the Play Console must match the Infisical values. ENV.fetch (not ENV[]) so a
# missing secret fails loudly instead of seeding an account with a blank, guessable login.
#
# Idempotent: find_or_initialize + save (re-)asserts the credentials without creating duplicates,
# so re-running always leaves a working review login. NOTE this file touches only the review
# account and its sample list — it never imports the catalog, so it is safe to load on its own
# against an existing production database (e.g. `bin/rails runner 'load "db/seeds/production.rb"'`)
# without clobbering backoffice-authored catalog data.

REVIEW_EMAIL    = ENV.fetch("PLAY_REVIEW_EMAIL")
REVIEW_PASSWORD = ENV.fetch("PLAY_REVIEW_PASSWORD")
REVIEW_USERNAME = "PlayReview"

review = User.find_or_initialize_by(email: REVIEW_EMAIL)
review.username = REVIEW_USERNAME
review.password = REVIEW_PASSWORD
review.admin = false
review.save!
puts "Seeded Play Store review account #{review.email} (admin: #{review.admin})."

# Give the reviewer a valid, populated gang so the app shows real functionality on first sign-in —
# an empty account can read as a broken app and get the submission rejected. Same known-good 100pt
# Guild roster the dev players use. Defensive: skip any reference the catalog lacks rather than
# aborting the whole seed.
# 150pt limit (a standard game size) so the roster below stays comfortably valid even if catalog
# costs drift by a point or two — a reviewer should see a green, playable gang, not a cost error.
review_list = Gang::List.find_or_create_by!(name: "Sample Guild Gang", faction: "guild") do |l|
  l.points = 150
  l.owner = review
end

review_identifiers = %w[
  guild-king-for-a-day
  guild-arbalest-a
  guild-citizen-a
  guild-gondolier-a
  guild-harlot-a
  guild-indebted-a
  guild-mariner-a
  guild-beggar-a
  guild-blooded-a
  guild-dog-a
  guild-pulcinella-a
]

card_refs = Catalog::CardReference.where(identifier: review_identifiers).index_by(&:identifier)
review_list.list_entries.destroy_all
review_identifiers.each_with_index do |id, position|
  cr = card_refs[id]
  next unless cr
  review_list.list_entries.create!(entry: cr, position: position + 1)
end

# Recompute the cached selection_valid/selection_errors now, rather than waiting on the list's
# after_commit callback — the app reads those cached columns, so the reviewer must see a valid gang.
review_list.refresh_selection_validity

puts "Seeded review sample list '#{review_list.name}' with #{review_list.list_entries.count} entries (valid: #{review_list.reload.selection_valid})."
