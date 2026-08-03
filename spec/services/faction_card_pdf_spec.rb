require "rails_helper"
require "tmpdir"

RSpec.describe FactionCardPdf do
  # Both the faces this reads and the PDFs it writes hang off Catalog::CardReference::IMAGES_DIR, so
  # one stub redirects the whole thing away from the real public/cards.
  let(:cards_dir) { Pathname(Dir.mktmpdir) }
  before { stub_const("Catalog::CardReference::IMAGES_DIR", cards_dir) }
  after { FileUtils.remove_entry(cards_dir) }

  # A stand-in for a rendered card face: a real WebP, tiny, and 4-band when it should exercise the
  # transparency-flattening path the catalog's actual faces take.
  def publish!(reference, alpha: false)
    image = Vips::Image.black(20, 34, bands: 3)
    image = image.bandjoin(255) if alpha
    image.webpsave(reference.front_path.to_s)
    image.webpsave(reference.back_path.to_s)
  end

  def profile_with_card(name:, keywords:, identifier:, faction: "guild")
    profile = create(:profile, faction: faction, name: name, keywords: keywords)
    create(:card_reference, profile: profile, identifier: identifier, name: name)
  end

  describe "page geometry" do
    it "lays two tarot-sized cards across an A4 page with equal margins" do
      expect(described_class::PAGE_W).to be_within(0.01).of(595.28)
      expect(described_class::PAGE_H).to be_within(0.01).of(841.89)

      # 70 × 120 mm exactly — the point of the whole exercise.
      expect(described_class::CARD_W).to be_within(0.01).of(198.43)
      expect(described_class::CARD_H).to be_within(0.01).of(340.16)

      # 25 mm side margins and 88.5 mm above/below, i.e. the pair is centred both ways.
      expect(described_class::LEFT).to be_within(0.01).of(25 * described_class::MM)
      expect(described_class::BOTTOM).to be_within(0.01).of(88.5 * described_class::MM)
      expect((described_class::LEFT * 2) + described_class::PAIR_W)
        .to be_within(0.01).of(described_class::PAGE_W)
    end

    it "keeps the crop marks inside the page and clear of the facing card" do
      left_card_right = described_class::LEFT + described_class::CARD_W
      right_card_left = left_card_right + described_class::GUTTER
      reach = described_class::MARK_GAP + described_class::MARK_LEN

      expect(described_class::LEFT - reach).to be > 0
      expect(described_class::BOTTOM - reach).to be > 0
      expect(left_card_right + reach).to be < right_card_left - reach
    end
  end

  describe ".role_rank" do
    it "ranks Leaders above Heroes above everyone else, matching the app" do
      leader = build(:profile, keywords: [ "Leader" ])
      hero = build(:profile, keywords: [ "Hero", "Doctor" ])
      henchman = build(:profile, keywords: [ "Henchman" ])

      expect(described_class.role_rank(leader)).to eq(0)
      expect(described_class.role_rank(hero)).to eq(1)
      expect(described_class.role_rank(henchman)).to eq(2)
    end

    it "ranks a Leader that also prints Hero as a Leader" do
      expect(described_class.role_rank(build(:profile, keywords: [ "Hero", "Leader" ]))).to eq(0)
    end
  end

  describe "#card_references" do
    it "orders by role, then alphabetically within each role" do
      profile_with_card(name: "Zealot", keywords: [ "Hero" ], identifier: "guild-zealot")
      profile_with_card(name: "Thug", keywords: [ "Henchman" ], identifier: "guild-thug")
      profile_with_card(name: "Il Capitano", keywords: [ "Leader" ], identifier: "guild-capitano")
      profile_with_card(name: "Acrobat", keywords: [ "Hero" ], identifier: "guild-acrobat")

      names = described_class.new("guild").card_references.map(&:name)

      expect(names).to eq([ "Il Capitano", "Acrobat", "Zealot", "Thug" ])
    end

    it "includes both halves of an A/B pair, in identifier order" do
      profile = create(:profile, faction: "guild", name: "Apprentice", keywords: [ "Hero" ])
      create(:card_reference, profile: profile, identifier: "guild-apprentice-b", illustration_number: 2)
      create(:card_reference, profile: profile, identifier: "guild-apprentice-a", illustration_number: 1)

      expect(described_class.new("guild").card_references.map(&:identifier))
        .to eq([ "guild-apprentice-a", "guild-apprentice-b" ])
    end

    it "leaves other factions out" do
      profile_with_card(name: "Rashaari", keywords: [ "Hero" ], identifier: "rashaar-one", faction: "rashaar")
      profile_with_card(name: "Guilder", keywords: [ "Hero" ], identifier: "guild-one")

      expect(described_class.new("guild").card_references.map(&:identifier)).to eq([ "guild-one" ])
    end
  end

  describe "#call" do
    it "writes a date-stamped PDF with one page per card" do
      publish!(profile_with_card(name: "Il Capitano", keywords: [ "Leader" ], identifier: "guild-capitano"))
      publish!(profile_with_card(name: "Acrobat", keywords: [ "Hero" ], identifier: "guild-acrobat"), alpha: true)

      path = described_class.call("guild", date: Date.new(2026, 8, 3))

      expect(path.basename.to_s).to eq("carnevale-guild-cards-2026-08-03.pdf")
      expect(path).to exist

      pdf = path.binread
      expect(pdf).to start_with("%PDF")
      # The page tree records its own size, and Prawn leaves that object uncompressed.
      expect(pdf).to include("/Count 2")
    end

    it "prints a name Prawn's built-in font could not set" do
      publish!(profile_with_card(name: "Cetean Upiór", keywords: [ "Hero" ], identifier: "guild-upior"))

      expect { described_class.call("guild") }.not_to raise_error
    end

    it "leaves out cards whose faces have not been published, and reports them" do
      publish!(profile_with_card(name: "Acrobat", keywords: [ "Hero" ], identifier: "guild-acrobat"))
      profile_with_card(name: "Unrendered", keywords: [ "Hero" ], identifier: "guild-unrendered")

      builder = described_class.new("guild")
      builder.call

      expect(builder.missing.map(&:identifier)).to eq([ "guild-unrendered" ])
      expect(builder.path.binread).to include("/Count 1")
    end

    it "refuses a faction whose cards have never been published" do
      profile_with_card(name: "Unrendered", keywords: [ "Hero" ], identifier: "guild-unrendered")

      expect { described_class.call("guild") }.to raise_error(described_class::Error, /have been published yet/)
    end

    it "refuses a faction with no cards at all" do
      expect { described_class.call("guild") }.to raise_error(described_class::Error, /No cards to print/)
    end

    it "refuses an unknown faction" do
      expect { described_class.call("borgias") }.to raise_error(described_class::Error, /Unknown faction/)
    end

    it "overwrites rather than accumulates when rebuilt the same day" do
      publish!(profile_with_card(name: "Acrobat", keywords: [ "Hero" ], identifier: "guild-acrobat"))

      2.times { described_class.call("guild", date: Date.new(2026, 8, 3)) }

      expect(described_class.output_dir.children.size).to eq(1)
    end
  end

  describe ".generate" do
    it "reports a failure instead of raising" do
      result = described_class.generate("guild")

      expect(result).not_to be_ok
      expect(result.faction).to eq("guild")
      expect(result.error).to match(/No cards to print/)
    end
  end

  describe ".generate_all" do
    it "builds what it can and reports the rest, in display order" do
      publish!(profile_with_card(name: "Acrobat", keywords: [ "Hero" ], identifier: "guild-acrobat"))
      publish!(profile_with_card(name: "Priest", keywords: [ "Hero" ], identifier: "vatican-priest",
        faction: "vatican"))

      results = described_class.generate_all(date: Date.new(2026, 8, 3))

      expect(results.map(&:faction)).to eq(described_class::DISPLAY_ORDER)
      expect(results.select(&:ok?).map(&:faction)).to eq(%w[guild vatican])
    end
  end

  describe ".latest" do
    def touch_sheet(faction, date)
      FileUtils.mkdir_p(described_class.output_dir)
      described_class.output_dir.join("carnevale-#{faction}-cards-#{date}.pdf").write("%PDF-1.4")
    end

    it "returns the newest sheet per faction, in display order" do
      touch_sheet("vatican", "2026-07-01")
      touch_sheet("guild", "2026-07-01")
      touch_sheet("guild", "2026-08-03")

      sheets = described_class.latest

      expect(sheets.map(&:faction)).to eq(%w[guild vatican])
      expect(sheets.first.date).to eq(Date.new(2026, 8, 3))
      expect(sheets.first.url).to eq("/cards/pdf/carnevale-guild-cards-2026-08-03.pdf")
    end

    it "ignores files that do not follow the naming convention" do
      FileUtils.mkdir_p(described_class.output_dir)
      described_class.output_dir.join("notes.txt").write("hello")
      described_class.output_dir.join("carnevale-guild-cards.pdf").write("%PDF-1.4")

      expect(described_class.latest).to be_empty
    end

    it "is empty before anything has been generated" do
      expect(described_class.latest).to be_empty
    end

    describe ".prune!" do
      it "keeps the most recent generations of each faction and deletes the rest" do
        %w[2026-06-01 2026-07-01 2026-08-01 2026-08-03].each { |date| touch_sheet("guild", date) }
        touch_sheet("vatican", "2026-06-01")

        described_class.prune!(keep: 2)

        expect(described_class.existing.map { |s| [ s.faction, s.date.iso8601 ] })
          .to contain_exactly([ "guild", "2026-08-01" ], [ "guild", "2026-08-03" ],
            [ "vatican", "2026-06-01" ])
      end
    end
  end
end
