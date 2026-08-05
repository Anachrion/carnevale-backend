require "rails_helper"
require "tmpdir"

RSpec.describe Catalog::CardReference do
  # Both directories the fingerprint reads live under a tmpdir, so a spec never writes into
  # public/cards or touches the committed illustrations.
  let(:images_dir) { Pathname(Dir.mktmpdir) }
  let(:illustrations_dir) { Pathname(Dir.mktmpdir) }

  let(:profile) { create(:profile, faction: :guild, ducats: 12) }
  let!(:illustration) { create(:illustration, profile: profile, number: 1, path: "p01.png") }
  let(:reference) { create(:card_reference, profile: profile, identifier: "guild-thief", illustration_number: 1) }

  before do
    stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
    stub_const("Catalog::CardReference::ILLUSTRATIONS_DIR", illustrations_dir)
    FileUtils.mkdir_p(illustrations_dir.join("guild"))
    File.binwrite(illustrations_dir.join("guild", "p01.png"), "original-art")
  end

  after do
    FileUtils.remove_entry(images_dir)
    FileUtils.remove_entry(illustrations_dir)
  end

  # Stand in for a render: write the faces, version them, then record what they were rendered
  # from — the same three steps the backoffice button and cards:render perform.
  def render!(ref = reference, front: "front-png")
    File.binwrite(ref.front_path, front)
    File.binwrite(ref.back_path, "back-png")
    ref.reversion!
    ref.stamp_source!
  end

  describe ".png_to_webp" do
    # An RGBA image standing in for a rendered card face: a colour gradient with a fully
    # transparent left strip, so the conversion has an alpha channel to carry through.
    let(:png) do
      require "vips"
      xy = Vips::Image.xyz(64, 64)
      r = xy.extract_band(0)
      g = xy.extract_band(1)
      b = (r + g).cast("uchar")
      alpha = (r < 32).ifthenelse(0, 255)
      r.bandjoin([ g, b, alpha ]).cast("uchar").copy(interpretation: "srgb").pngsave_buffer
    end

    it "produces a valid WebP that keeps the pixels and the transparent corners" do
      webp = described_class.png_to_webp(png)

      # RIFF/WEBP container magic, and it decodes back to the same size with its alpha intact.
      expect(webp.byteslice(0, 4)).to eq("RIFF")
      expect(webp.byteslice(8, 4)).to eq("WEBP")

      decoded = Vips::Image.new_from_buffer(webp, "")
      expect([ decoded.width, decoded.height ]).to eq([ 64, 64 ])
      expect(decoded.has_alpha?).to be(true)
    end
  end

  describe "#stale?" do
    it "is stale when the images were never rendered" do
      expect(reference).to be_stale
    end

    it "is stale when the images exist but nothing was recorded about their sources" do
      File.binwrite(reference.front_path, "front-png")
      File.binwrite(reference.back_path, "back-png")

      expect(reference.source_digest).to be_nil
      expect(reference).to be_stale
    end

    it "is not stale right after a render" do
      render!

      expect(reference.reload).not_to be_stale
    end

    it "is stale when a face is deleted from disk" do
      render!
      File.delete(reference.front_path)

      expect(reference).to be_stale
    end

    it "is stale when a printed stat changes" do
      render!
      profile.update!(ducats: 99)

      expect(reference.reload).to be_stale
    end

    it "is stale when a printed weapon changes" do
      weapon = Catalog::Weapon.create!(name: "Stiletto", damage: 3)
      Catalog::ProfileWeapon.create!(profile: profile, weapon: weapon, position: 1)
      render!(reference.reload)

      weapon.update!(damage: 5)

      expect(reference.reload).to be_stale
    end

    it "is stale when the illustration is repositioned" do
      render!
      illustration.update!(zoom: 150, offset_x: 20)

      expect(reference.reload).to be_stale
    end

    it "is stale when the illustration file is re-exported with different bytes" do
      render!
      File.binwrite(illustrations_dir.join("guild", "p01.png"), "retouched-art")

      expect(reference.reload).to be_stale
    end

    it "is stale when the card template changes" do
      render!

      template = Pathname(Dir.mktmpdir).join("motif.png")
      File.binwrite(template, "v1")
      allow(described_class).to receive(:template_files).and_return([ template ])
      expect(reference.reload).to be_stale # the fingerprint no longer matches the stamped one

      # And a fresh render against that template settles again, until the template moves on.
      render!(reference)
      expect(reference.reload).not_to be_stale

      File.binwrite(template, "v2")
      expect(reference.reload).to be_stale
    end

    it "ignores changes that never reach the card" do
      render!
      profile.touch

      expect(reference.reload).not_to be_stale
    end

    # B-31: a reference whose own slot has no art renders with the first illustration (the `card`
    # action's fallback). Its fingerprint must reflect that same art, or repositioning the art it
    # was actually drawn with would never mark it stale.
    it "marks a fallback-rendered card stale when the art it borrowed is repositioned" do
      ref_b = create(:card_reference, profile: profile, identifier: "guild-thief-b", illustration_number: 2)
      expect(ref_b.illustration).to eq(illustration) # slot 2 has no art -> falls back to slot 1

      render!(ref_b)
      expect(ref_b.reload).not_to be_stale

      illustration.update!(zoom: 150, offset_x: 20)
      expect(ref_b.reload).to be_stale
    end
  end

  # The digest is what makes a template edit a catalog-wide event, so what it chooses to ignore
  # matters as much as what it catches: every false positive costs a full pass through headless
  # Chrome to re-render 375 byte-identical faces.
  describe ".template_digest" do
    let(:dir) { Pathname(Dir.mktmpdir) }

    # A fresh path each time: template_digest memoises against the files' mtimes, and a rewrite
    # within the same second would otherwise be served from that cache rather than re-hashed.
    def digest_for(name, body)
      path = dir.join(name)
      path.write(body)
      allow(described_class).to receive(:template_files).and_return([ path ])
      described_class.template_digest
    end

    after { FileUtils.remove_entry(dir) }

    it "ignores a licence header added to a helper" do
      bare = digest_for("a.rb", "def draw\n  42\nend\n")
      headed = digest_for("b.rb", "# Copyright 2026 Anachrion\n#\n# Licensed under the AGPL.\n\ndef draw\n  42\nend\n")

      expect(headed).to eq(bare)
    end

    it "ignores comments and blank lines in an ERB template" do
      bare = digest_for("a.erb", "<span>x</span>\n")
      commented = digest_for("b.erb", "<%# the name banner %>\n<!-- top row: ducats -->\n\n<span>x</span>\n")

      expect(commented).to eq(bare)
    end

    # "#" opens a comment in the helper but a CSS id selector in the template. Applying the Ruby
    # rule to the ERB would hash away #front-card and friends, and a restyle of the card frame
    # would then never mark anything stale.
    it "keeps CSS id selectors in an ERB template" do
      without = digest_for("a.erb", "<style>\n  .card { color: red; }\n</style>\n")
      with_id = digest_for("b.erb", "<style>\n  #front-card { color: red; }\n  .card { color: red; }\n</style>\n")

      expect(with_id).not_to eq(without)
    end

    it "still catches a change to what the template draws" do
      before_change = digest_for("a.erb", "<span>ducats</span>\n")
      after_change = digest_for("b.erb", "<span>ducats!</span>\n")

      expect(after_change).not_to eq(before_change)
    end

    it "still catches a change to a helper's code" do
      before_change = digest_for("a.rb", "# unchanged prose\ndef draw\n  42\nend\n")
      after_change = digest_for("b.rb", "# unchanged prose\ndef draw\n  43\nend\n")

      expect(after_change).not_to eq(before_change)
    end

    # Card-template assets have no comment syntax to strip, so they are hashed whole — a motif
    # whose bytes change has to move the digest.
    it "hashes non-source template assets by their bytes" do
      before_change = digest_for("motif-v1.png", "v1")
      after_change = digest_for("motif-v2.png", "v2")

      expect(after_change).not_to eq(before_change)
    end
  end

  describe "#source_fingerprint" do
    it "is stable across calls when nothing changes" do
      expect(reference.source_fingerprint).to eq(reference.source_fingerprint)
    end

    it "differs between the two references of an A/B pair" do
      create(:illustration, profile: profile, number: 2, path: "p02.png")
      File.binwrite(illustrations_dir.join("guild", "p02.png"), "other-art")
      other = create(:card_reference, profile: profile, identifier: "guild-thief-b", illustration_number: 2)

      expect(other.source_fingerprint).not_to eq(reference.source_fingerprint)
    end
  end

  describe ".stale" do
    it "returns only the references whose images are out of date" do
      fresh = create(:card_reference, profile: profile, identifier: "guild-fresh", illustration_number: 1)
      render!(reference)
      render!(fresh)

      illustration.update!(flipped: true)
      fresh.update!(illustration_number: 2) # no illustration #2 exists, so its art is gone

      expect(described_class.stale.map(&:identifier)).to contain_exactly("guild-thief", "guild-fresh")
    end

    it "is empty when every card has just been rendered" do
      render!

      expect(described_class.stale).to be_empty
    end
  end

  describe "#stamp_source! and #reversion!" do
    it "tracks the sources and the bytes independently" do
      render!
      expect(reference.reload.internal_version).to eq(1)

      # Art changes, but the card has not been re-rendered: stale, yet the app is told nothing,
      # because the bytes it downloads have not moved.
      illustration.update!(zoom: 130)
      expect(reference.reload).to be_stale
      expect(reference.reversion!).to eq(:unchanged)
      expect(reference.reload.internal_version).to eq(1)

      # Re-render: new bytes on disk, so the version bumps and the app re-syncs this card.
      render!(reference, front: "front-png-v2")

      expect(reference.reload.internal_version).to eq(2)
      expect(reference).not_to be_stale
    end
  end
end
