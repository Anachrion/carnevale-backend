require "rails_helper"

RSpec.describe Catalog::History do
  let(:profile) { create(:profile, name: "Capodecina", ducats: 20) }

  describe ".record!" do
    it "writes a baseline first when the card has no history yet, so the first diff is complete" do
      before = Catalog::CardSnapshot.capture(profile)
      profile.update!(ducats: 25)

      version = described_class.record!(profile, event: "update", before: before)

      expect(described_class.versions_for(profile).map(&:event)).to eq(%w[baseline update])
      expect(described_class.changes(version)).to eq([ "Ducats: 20 → 25" ])
    end

    it "writes nothing for an edit that changed nothing" do
      expect(described_class.record!(profile, event: "update", before: Catalog::CardSnapshot.capture(profile))).to be_nil
      expect(described_class.versions_for(profile)).to be_empty
    end

    it "records the author paper_trail knows about" do
      admin = create(:user, :admin)
      before = Catalog::CardSnapshot.capture(profile)
      profile.update!(ducats: 25)

      version = PaperTrail.request(whodunnit: admin.id) { described_class.record!(profile, event: "update", before: before) }

      expect(version.whodunnit).to eq(admin.id.to_s)
      expect(described_class.authors([ version ])).to eq(admin.id.to_s => admin.username)
    end
  end

  describe "shared records" do
    it "versions weapons on their own, field by field" do
      weapon = Catalog::Weapon.create!(name: "Stiletto", damage: 1)
      weapon.update!(damage: 2)

      version = described_class.versions_for(weapon).last
      expect(described_class.changes(version)).to eq([ "Damage: 1 → 2" ])
    end
  end
end
