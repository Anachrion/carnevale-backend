require "rails_helper"

RSpec.describe CompanionSyncService do
  # A parent profile (an Emissary) that brings `companion_count` distinct companions, each with the
  # given base/upgraded quantities, plus its own card reference to hire it by.
  def build_parent(companion_count: 2, base: 1, upgraded: 2, upgrade_ducats: 12)
    parent = create(:profile, faction: :rashaar, ducats: 50, companion_upgrade_ducats: upgrade_ducats,
                    keywords: ["Hero"])
    companion_count.times do
      companion = create(:profile, faction: :rashaar, ducats: 0, recruitable: false, keywords: ["Henchman"])
      create(:card_reference, profile: companion)
      create(:profile_companion, profile: parent, companion_profile: companion,
             base_quantity: base, upgraded_quantity: upgraded)
    end
    parent
  end

  let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:list) { create(:list, owner: user, faction: :rashaar, points: 300) }

  def hire(profile)
    ref = create(:card_reference, profile: profile)
    entry = list.list_entries.create!(entry_type: "Catalog::CardReference", entry_id: ref.id,
                                      position: (list.list_entries.maximum(:position) || 0) + 1)
    described_class.call(entry)
    entry
  end

  it "adds one of each companion when the parent is hired" do
    entry = hire(build_parent(companion_count: 2))

    expect(entry.companion_entries.count).to eq(2)
    expect(entry.companion_entries.all? { |e| e.profile.recruitable == false }).to be(true)
  end

  it "doubles the companions to the upgraded quantity when the upgrade is selected" do
    entry = hire(build_parent(companion_count: 4, base: 1, upgraded: 2))
    entry.update!(upgrade_selected: true)

    described_class.call(entry)

    expect(entry.companion_entries.reload.count).to eq(8)
  end

  it "drops the extra companions again when the upgrade is deselected" do
    entry = hire(build_parent(companion_count: 4))
    entry.update!(upgrade_selected: true)
    described_class.call(entry)
    entry.update!(upgrade_selected: false)

    described_class.call(entry)

    expect(entry.companion_entries.reload.count).to eq(4)
  end

  it "is idempotent — re-running doesn't pile up duplicate companions" do
    entry = hire(build_parent(companion_count: 4))

    described_class.call(entry)
    described_class.call(entry)

    expect(entry.companion_entries.reload.count).to eq(4)
  end

  it "marks companion entries as non-summoned so they count towards the gang-building rules" do
    entry = hire(build_parent(companion_count: 2))

    expect(entry.companion_entries.any?(&:summoned?)).to be(false)
  end

  it "does nothing for a profile that brings no companions" do
    plain = create(:profile, faction: :rashaar, ducats: 20)

    entry = hire(plain)

    expect(entry.companion_entries.count).to eq(0)
    expect(list.list_entries.count).to eq(1)
  end

  it "cascades: destroying the parent removes its companions" do
    entry = hire(build_parent(companion_count: 4))
    expect(list.list_entries.count).to eq(5)

    entry.destroy

    expect(list.list_entries.reload.count).to eq(0)
  end
end
