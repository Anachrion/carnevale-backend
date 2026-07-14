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
