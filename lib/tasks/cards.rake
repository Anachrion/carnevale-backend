namespace :cards do
  # Render card faces into public/cards, exactly as the backoffice's "render to catalog" button
  # does — both faces of every card reference. The front is drawn with the reference's own
  # illustration, so an A/B pair delivers two different cards; the back has no illustration, so it
  # is rendered once per profile and written to each of its references.
  #
  # Grover drives headless Chrome against a *running* server, so boot one first, then:
  #   bin/rails cards:render                # every card
  #   bin/rails 'cards:render[doctors]'     # one faction
  #
  # Set CARD_RENDER_BASE_URL if that server is not on http://localhost:3000.
  # Idempotent: re-rendering unchanged art rewrites identical bytes, and reversion then leaves the
  # version alone, so only genuinely changed cards are advertised to the app as new.
  desc "Render card images into public/cards (needs a running server)"
  task :render, [ :faction ] => :environment do |_t, args|
    require "grover"

    base  = ENV["CARD_RENDER_BASE_URL"].presence || "http://localhost:3000"
    scope = Catalog::Profile.includes(:card_references, :illustrations).order(:faction, :name)
    scope = scope.where(faction: args[:faction]) if args[:faction].present?

    dest = Catalog::CardReference::IMAGES_DIR
    FileUtils.mkdir_p(dest)

    options = {
      emulate_media: "screen",
      viewport: { width: 265, height: 454, device_scale_factor: 3 },
      print_background: true,
      omit_background: true,
      launch_args: [ "--no-sandbox", "--disable-setuid-sandbox" ]
    }

    url_for = lambda do |profile, side, illustration|
      Rails.application.routes.url_helpers.card_backoffice_profile_url(
        profile, host: base, side: side, illustration: illustration,
        render_token: Backoffice::BaseController.render_token
      )
    end

    # Grover only emits PNG; the catalog is served as WebP (same pixels, ~7× smaller), so each face
    # is converted before it lands in public/cards. The back is converted once per profile.
    fronts = backs = 0
    scope.find_each do |profile|
      back_webp = Catalog::CardReference.png_to_webp(Grover.new(url_for.(profile, "back", nil), **options).to_png)

      profile.card_references.each do |cr|
        front_png = Grover.new(url_for.(profile, "front", cr.illustration_number), **options).to_png
        File.binwrite(cr.front_path, Catalog::CardReference.png_to_webp(front_png))
        File.binwrite(cr.back_path, back_webp)
        cr.stamp_source!
        fronts += 1
        backs += 1
      end
      print "."
    end
    puts

    puts "cards:render — wrote #{fronts} fronts and #{backs} backs into #{dest}"
    Rake::Task["cards:reversion"].invoke
  end

  # Delete images in public/cards that no card reference points at any more — e.g. the shared front
  # a profile's A/B references used before each gained its own, or the .png faces left behind by the
  # move to WebP.
  desc "Remove card images no card reference points at"
  task prune: :environment do
    require "set"

    dest = Catalog::CardReference::IMAGES_DIR
    in_use = Catalog::CardReference.includes(:profile)
      .flat_map { |cr| [ cr.card_front, cr.card_back ] }.to_set
    orphans = Dir.children(dest).select do |f|
      (f.end_with?(".webp") || f.end_with?(".png")) && !in_use.include?(f)
    end

    orphans.each { |f| File.delete(dest.join(f)) }
    puts "cards:prune — deleted #{orphans.size} orphaned image(s); #{in_use.size} still in use"
    orphans.first(10).each { |f| puts "  #{f}" }
  end

  # Declare the images already on disk to be current, without re-rendering them: stamp each card's
  # sources as the baseline stale? compares against. This is the cheap way to start tracking
  # staleness on a catalog rendered before source_digest existed — but it *asserts* that every PNG
  # in public/cards matches today's stats and art. Re-render anything you know has drifted first
  # (or run cards:render instead, which renders and stamps in one go).
  desc "Baseline source tracking on the images already in public/cards (renders nothing)"
  task baseline: :environment do
    refs = Catalog::CardReference.includes(:profile).select { |cr| cr.source_digest.nil? }
    refs.each(&:stamp_source!)

    puts "cards:baseline — stamped #{refs.size} card(s) as rendered from their current sources"
  end

  # List the cards whose images in public/cards no longer match the stats, art or template they
  # were rendered from — i.e. what `cards:render` would actually change. Read-only.
  desc "List cards whose images are out of date"
  task stale: :environment do
    stale = Catalog::CardReference.stale

    if stale.empty?
      puts "cards:stale — every card is up to date"
    else
      puts "cards:stale — #{stale.size} card(s) out of date:"
      stale.sort_by(&:identifier).each { |cr| puts "  #{cr.identifier}" }
      puts "Run `bin/rails cards:render` (server must be up) to bring them into line."
    end
  end

  # Bump internal_version for cards whose image bytes changed since the last run. Safe to run
  # repeatedly; only cards with a changed digest are touched. Also invoked at the end of seeds.
  desc "Bump internal_version for cards whose images changed"
  task reversion: :environment do
    tally = Hash.new(0)

    Catalog::CardReference.includes(:profile).find_each do |cr|
      tally[cr.reversion!] += 1
    end

    puts "cards:reversion — baselined #{tally[:baselined]}, bumped #{tally[:bumped]}, " \
         "unchanged #{tally[:unchanged]}, missing images #{tally[:missing]}"
  end

  # Build the printable per-faction PDFs the public /cards page hands out (see FactionCardPdf).
  #
  #   bin/rails cards:pdf                 # every faction
  #   bin/rails 'cards:pdf[doctors]'      # one faction
  #
  # Unlike cards:render this needs no running server and no Chrome — it assembles the faces already
  # in public/cards, so run it *after* publishing, not instead of it. The file name carries the day
  # it was built, and the sheet it supersedes is deleted.
  desc "Build the printable faction card PDFs into public/cards/pdf"
  task :pdf, [ :faction ] => :environment do |_t, args|
    results = if args[:faction].present?
      [ FactionCardPdf.generate(args[:faction]) ].tap { FactionCardPdf.prune! }
    else
      FactionCardPdf.generate_all
    end

    results.each do |result|
      if result.ok?
        note = result.missing.positive? ? " (left out #{result.missing} unpublished card(s))" : ""
        puts "cards:pdf — #{result.path.basename} · " \
             "#{ActiveSupport::NumberHelper.number_to_human_size(result.path.size)}#{note}"
      else
        warn "cards:pdf — skipped #{result.faction}: #{result.error}"
      end
    end
  end
end
