# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# A printable, date-stamped PDF of every card in one faction — the file the public /cards page
# hands out.
#
# One A4 page per card, front and back side by side at exactly 70 × 120 mm (tarot), with crop marks
# to cut against. Pages run in the app's own "role" order — Leaders, then Heroes, then Henchmen,
# alphabetical within each band — so a printed stack collates the same way the Cards screen reads
# (see _roleRank in the frontend's cards_screen.dart).
#
# It assembles the faces *already rendered* into public/cards rather than driving headless Chrome
# itself, which is what makes it cheap enough to run from a web request: a faction is a couple of
# seconds instead of the minutes a Grover pass costs. The consequence is that this only ever prints
# what was last published — regenerate the PDFs *after* "Publish cards", never instead of it.
class FactionCardPdf
  class Error < StandardError; end

  # Prawn works in PostScript points; every dimension below is authored in millimetres.
  MM = 72.0 / 25.4

  PAGE_W = 210 * MM
  PAGE_H = 297 * MM

  # Tarot. The catalog faces are 795 × 1362 px, an aspect 0.06% off this — they are drawn to these
  # exact dimensions rather than fitted, so the trim size (and the crop marks around it) is right to
  # the millimetre and the distortion stays four orders of magnitude below anything a printer resolves.
  CARD_W = 70 * MM
  CARD_H = 120 * MM

  GUTTER = 20 * MM

  # 25 mm side margins, and the pair sits vertically centred with 88.5 mm above and below.
  PAIR_W = (CARD_W * 2) + GUTTER
  LEFT   = (PAGE_W - PAIR_W) / 2
  BOTTOM = (PAGE_H - CARD_H) / 2

  # Hairlines set back from the trim edge, so the marks themselves are never cut through.
  MARK_GAP = 2 * MM
  MARK_LEN = 4 * MM
  MARK_COLOR = "9ca3af"

  # The faces are WebP with transparent rounded corners; PDF wants something it can embed. JPEG
  # rather than PNG: these are photographic illustrations, and a 55-page faction as PNG runs to
  # ~200 MB against ~25 MB here. 92 keeps the printed stat text free of visible ringing at the
  # 288 dpi the faces are rendered at. Baseline (vips' default) — PDF's DCTDecode is not progressive.
  JPEG_QUALITY = 92

  # The footer is set in the cards' own body face, embedded rather than left to Prawn's built-in
  # Helvetica: that one is limited to WinAnsi and raises outright on anything outside it, which a
  # model name is one accent away from (Cetean Upiór today, a typographic apostrophe tomorrow).
  FOOTER_FONT = Rails.root.join("public", "fonts", "EBGaramond-Regular.ttf").freeze

  FILENAME_PATTERN = /\Acarnevale-(?<faction>[a-z]+)-cards-(?<date>\d{4}-\d{2}-\d{2})\.pdf\z/

  # The order the factions are offered in, matching the app's create-gang picker
  # (kCreateGangFactions) rather than the alphabetical order the enum happens to declare.
  DISPLAY_ORDER = %w[guild doctors vatican patricians strigoi gifted rashaar].freeze

  # One generated file on disk, as the public page needs to describe it.
  Sheet = Struct.new(:faction, :date, :path, keyword_init: true) do
    # ?v= busted by the file's mtime, the same trick Catalog::CardReference#image_urls uses on the
    # faces and for the same reason: public/ is served "max-age=1 year, immutable", and the date in
    # the name only changes once a day. Rebuild after fixing a typo this afternoon and the URL is
    # byte-for-byte the one someone loaded this morning — "immutable" means their browser would not
    # even revalidate, so they would keep the typo for a year. mtime rather than a digest of the
    # content because this is read on every page render and the files are ~25 MB each.
    #
    # The query does not reach the saved filename: <a download> takes that from the URL's path.
    def url = "/cards/pdf/#{path.basename}?v=#{path.mtime.to_i}"
    def byte_size = path.size
  end

  # The outcome of building one faction: the file written, how many of its cards were left out for
  # want of published faces, and — when nothing could be written at all — why.
  Result = Struct.new(:faction, :path, :missing, :error, keyword_init: true) do
    def ok? = path.present?
  end

  attr_reader :faction, :date, :missing

  # Resolved on each call rather than frozen into a constant, so it follows
  # Catalog::CardReference::IMAGES_DIR — which is what lets a spec point the faces this reads and the
  # PDFs it writes at one throwaway directory.
  def self.output_dir
    Catalog::CardReference::IMAGES_DIR.join("pdf")
  end

  def self.factions
    (DISPLAY_ORDER & HasFaction::FACTIONS) | HasFaction::FACTIONS
  end

  # Build the sheet for one faction. Returns the Pathname written; raises Error if it cannot.
  def self.call(faction, date: Date.current)
    new(faction, date: date).call
  end

  # Same, reported rather than raised — a faction whose cards have never been published must not
  # cost the other six their sheets.
  def self.generate(faction, date: Date.current)
    builder = new(faction, date: date)
    Result.new(faction: builder.faction, path: builder.call, missing: builder.missing.size)
  rescue Error => e
    Result.new(faction: faction.to_s, missing: 0, error: e.message)
  end

  # Build every faction, then drop each one's superseded sheets. Returns one Result per faction, in
  # DISPLAY_ORDER.
  def self.generate_all(date: Date.current)
    results = factions.map { |faction| generate(faction, date: date) }
    prune!
    results
  end

  # The newest sheet per faction, in DISPLAY_ORDER, skipping factions never generated.
  def self.latest
    by_faction = existing.group_by(&:faction)
    factions.filter_map { |faction| by_faction[faction]&.max_by(&:date) }
  end

  # Every generated sheet on disk, oldest first. Files that do not match the naming convention are
  # ignored rather than guessed at.
  def self.existing
    return [] unless output_dir.exist?

    output_dir.children.filter_map do |path|
      match = FILENAME_PATTERN.match(path.basename.to_s)
      next unless match

      Sheet.new(faction: match[:faction], date: Date.parse(match[:date]), path: path)
    end.sort_by(&:date)
  end

  # Delete every sheet a faction has apart from its newest. Nothing links the older ones — the page
  # and the publish screen both show only the newest — and they are regenerable in seconds from the
  # faces on disk, so keeping them buys nothing and costs ~165 MB of the cards volume per generation.
  def self.prune!
    existing.group_by(&:faction).each_value do |sheets|
      sheets.sort_by(&:date)[0...-1].each { |sheet| sheet.path.delete }
    end
  end

  # Leaders first, then Heroes, then everyone else — the same ranking the app's Cards and Hire
  # screens sort by, so "by role" means one thing across the app and the print sheets.
  def self.role_rank(profile)
    keywords = Array(profile.keywords)
    return 0 if keywords.include?("Leader")
    return 1 if keywords.include?("Hero")

    2
  end

  def initialize(faction, date: Date.current)
    raise Error, "Unknown faction #{faction.inspect}" unless HasFaction::FACTIONS.include?(faction.to_s)

    @faction = faction.to_s
    @date = date
    # References whose faces have not been rendered into public/cards yet. They are skipped rather
    # than fatal: one un-published card must not cost the faction its whole print sheet.
    @missing = []
  end

  def filename
    "carnevale-#{faction}-cards-#{date.iso8601}.pdf"
  end

  def path
    self.class.output_dir.join(filename)
  end

  def call
    require "prawn"

    references = card_references
    raise Error, "No cards to print for #{faction}." if references.empty?

    printable = references.select { |ref| ref.front_path.exist? && ref.back_path.exist? }
    @missing = references - printable
    raise Error, "None of #{faction}'s #{references.size} cards have been published yet." if printable.empty?

    FileUtils.mkdir_p(self.class.output_dir)
    path.binwrite(render(printable))
    path
  end

  # This faction's cards, in the order they are printed: profiles by role then name, and an A/B pair
  # contributing both of its references (each with its own front art and a copy of the shared back).
  def card_references
    Catalog::Profile
      .where(faction: faction)
      .includes(:card_references)
      .to_a
      .sort_by { |profile| [ self.class.role_rank(profile), profile.name.to_s ] }
      .flat_map(&:card_references)
  end

  private

  def render(references)
    pdf = Prawn::Document.new(
      page_size: [ PAGE_W, PAGE_H ],
      margin: 0,
      info: {
        Title: "Carnevale Companion — #{faction.capitalize} cards (#{date.iso8601})",
        Creator: "Carnevale Companion",
        CreationDate: Time.current
      }
    )

    # Falls back to the built-in font if the file ever goes missing, rather than failing the build
    # over a footer.
    if FOOTER_FONT.file?
      pdf.font_families.update("EB Garamond" => { normal: FOOTER_FONT.to_s })
      pdf.font "EB Garamond"
    end

    references.each_with_index do |reference, index|
      pdf.start_new_page if index.positive?
      draw_card(pdf, reference.front_path, LEFT)
      draw_card(pdf, reference.back_path, LEFT + CARD_W + GUTTER)
      draw_footer(pdf, reference, index + 1, references.size)
    end

    pdf.render
  end

  def draw_card(pdf, image_path, x)
    # Identical bytes are embedded once: Prawn keys its image registry on the data's digest, which
    # is what keeps an A/B pair's two copies of the same back from doubling the file.
    pdf.image StringIO.new(jpeg_bytes(image_path)),
      at: [ x, BOTTOM + CARD_H ], width: CARD_W, height: CARD_H

    crop_marks(pdf, x)
  end

  def crop_marks(pdf, x)
    left, right = x, x + CARD_W
    bottom, top = BOTTOM, BOTTOM + CARD_H

    pdf.save_graphics_state do
      pdf.line_width 0.25
      pdf.stroke_color MARK_COLOR

      [ bottom, top ].each do |y|
        pdf.stroke_line(left - MARK_GAP - MARK_LEN, y, left - MARK_GAP, y)
        pdf.stroke_line(right + MARK_GAP, y, right + MARK_GAP + MARK_LEN, y)
      end

      [ left, right ].each do |mark_x|
        pdf.stroke_line(mark_x, bottom - MARK_GAP - MARK_LEN, mark_x, bottom - MARK_GAP)
        pdf.stroke_line(mark_x, top + MARK_GAP, mark_x, top + MARK_GAP + MARK_LEN)
      end
    end
  end

  # A discreet line well below the trim area, so a sheet that has come loose from the stack still
  # says which model, which faction and which generation of the cards it is.
  def draw_footer(pdf, reference, page, total)
    pdf.save_graphics_state do
      pdf.fill_color "9ca3af"
      pdf.font_size 8

      pdf.text_box reference.name.to_s,
        at: [ LEFT, 14 * MM ], width: PAIR_W / 2, height: 5 * MM, overflow: :shrink_to_fit

      pdf.text_box "#{faction.capitalize} · #{date.iso8601} · #{page}/#{total}",
        at: [ LEFT + (PAIR_W / 2), 14 * MM ], width: PAIR_W / 2, height: 5 * MM,
        align: :right, overflow: :shrink_to_fit
    end
  end

  # A catalog face, ready to embed: the transparent rounded corners are flattened onto white (the
  # paper's colour anyway) so the JPEG, which has no alpha channel, does not render them black.
  def jpeg_bytes(image_path)
    require "vips"

    image = Vips::Image.new_from_file(image_path.to_s)
    image = image.flatten(background: [ 255, 255, 255 ]) if image.has_alpha?
    image.jpegsave_buffer(Q: JPEG_QUALITY, optimize_coding: true)
  end
end
