namespace :cards do
  # Copy the pre-rendered card faces into public/cards so the backend can host them.
  # Source defaults to the sibling frontend repo's asset dir; override for CI/other checkouts:
  #   bin/rails 'cards:import_images[/path/to/assets/images/cards]'
  # Idempotent: files with identical bytes are skipped. Re-run whenever the art changes, then
  # run cards:reversion to bump internal_version for the cards that actually changed.
  desc "Copy card front/back PNGs into public/cards"
  task :import_images, [ :source_dir ] => :environment do |_t, args|
    require "fileutils"

    source = Pathname.new(args[:source_dir].presence || File.expand_path("~/Workspace/carnevale/assets/images/cards"))
    abort "Source directory not found: #{source}" unless source.directory?

    dest = Catalog::CardReference::IMAGES_DIR
    FileUtils.mkdir_p(dest)

    copied = skipped = missing = 0
    filenames = Catalog::CardReference.pluck(:card_front, :card_back).flatten.compact.uniq
    filenames.each do |name|
      src = source.join(name)
      unless src.file?
        warn "  missing source image: #{name}"
        missing += 1
        next
      end

      target = dest.join(name)
      if target.file? && FileUtils.identical?(src, target)
        skipped += 1
      else
        FileUtils.cp(src, target)
        copied += 1
      end
    end

    puts "cards:import_images — copied #{copied}, skipped #{skipped} (unchanged), missing #{missing} of #{filenames.size} image files into #{dest}"
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
end
