require "rails_helper"

RSpec.describe Catalog::AbilityRename do
  let!(:acrobatic) { create(:ability, category: "character", name: "Acrobatic") }
  let!(:brave)     { create(:ability, category: "character", name: "Brave") }
  let!(:blast)     { create(:ability, category: "weapon", name: "Blast") }

  it "renames the ability on every profile listing it, keeping each rating" do
    capo = create(:profile, name: "Capodecina", abilities: [ "Acrobatic (2)", "Brave" ])
    bravo = create(:profile, name: "Bravo", abilities: [ "Acrobatic" ])
    other = create(:profile, name: "Other", abilities: [ "Brave" ])

    rewritten = described_class.call(acrobatic, "Acrobatics")

    expect(acrobatic.reload.name).to eq("Acrobatics")
    expect(rewritten).to contain_exactly(capo, bravo)
    expect(capo.reload.abilities).to eq([ "Acrobatics (2)", "Brave" ])
    expect(bravo.reload.abilities).to eq([ "Acrobatics" ])
    expect(other.reload.abilities).to eq([ "Brave" ])
  end

  it "records a card version for each profile it changed" do
    capo = create(:profile, abilities: [ "Acrobatic (2)" ])

    described_class.call(acrobatic, "Acrobatics")

    version = Catalog::History.versions_for(capo).last
    expect(Catalog::History.changes(version)).to eq([ "Abilities: +Acrobatics (2), −Acrobatic (2)" ])
  end

  it "renames a weapon ability on weapons, not on profiles" do
    musket = Catalog::Weapon.create!(name: "Musket", damage: 3, abilities: [ "Blast (2)" ])
    profile = create(:profile, abilities: [ "Brave" ])

    described_class.call(blast, "Explosive")

    expect(musket.reload.abilities).to eq([ "Explosive (2)" ])
    expect(profile.reload.abilities).to eq([ "Brave" ])
  end

  it "only updates other fields when the name is unchanged" do
    capo = create(:profile, abilities: [ "Acrobatic (2)" ])

    expect(described_class.call(acrobatic, "Acrobatic", description: "New text.")).to be_empty
    expect(acrobatic.reload.description).to eq("New text.")
    expect(Catalog::History.versions_for(capo)).to be_empty
  end

  it "writes nothing when the new name is taken" do
    capo = create(:profile, abilities: [ "Acrobatic (2)" ])

    expect { described_class.call(acrobatic, "Brave") }.to raise_error(ActiveRecord::RecordInvalid)
    expect(acrobatic.reload.name).to eq("Acrobatic")
    expect(capo.reload.abilities).to eq([ "Acrobatic (2)" ])
  end
end
