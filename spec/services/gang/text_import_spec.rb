require 'rails_helper'

RSpec.describe Gang::TextImport do
  let(:user) { create(:user) }

  def model!(name, faction: "guild", recruitable: true)
    profile = create(:profile, name: name, faction: faction, recruitable: recruitable)
    create(:card_reference, profile: profile, identifier: "#{faction}-#{name.parameterize}-a")
    profile
  end

  def text(models, header: "Carnevale gang: Imported\nFaction: guild\nDucats: 150")
    "#{header}\n\nModels\n#{models}\n"
  end

  it "creates a new list rather than touching an existing one" do
    model!("Bravo")
    existing = create(:list, owner: user, name: "Untouched")

    result = described_class.call(text("- Bravo"), owner: user)

    expect(result.list.id).not_to eq(existing.id)
    expect(result.list.name).to eq("Imported")
    expect(existing.reload.name).to eq("Untouched")
  end

  # A gang naming one profile this build does not know should still import the rest — losing a
  # whole list to a single typo would be the worst possible failure mode for a paste-in format.
  it "skips a name it cannot resolve and imports the rest" do
    model!("Bravo")

    result = described_class.call(text("- Bravo\n- Nonesuch\n- Bravo"), owner: user)

    expect(result.list.list_entries.count).to eq(2)
    expect(result.warnings).to include(a_string_matching(/unknown model 'Nonesuch'/))
  end

  # The Emissary's Tentacles arrive with their parent; a hand-edited list naming one directly must
  # not be able to conjure a free model.
  it "refuses a model that cannot be hired on its own" do
    model!("Dagger Tentacle", recruitable: false)

    result = described_class.call(text("- Dagger Tentacle"), owner: user)

    expect(result.list.list_entries).to be_empty
    expect(result.warnings).to include(a_string_matching(/cannot be hired on its own/))
  end

  it "regenerates companions instead of expecting them in the text" do
    parent = model!("Emissary of Mother Hydra")
    tentacle = model!("Dagger Tentacle", recruitable: false)
    create(:profile_companion, profile: parent, companion_profile: tentacle, base_quantity: 2, upgraded_quantity: 4)

    result = described_class.call(text("- Emissary of Mother Hydra\n  Upgrade"), owner: user)

    entry = result.list.list_entries.find { |e| e.profile&.name == "Emissary of Mother Hydra" }
    expect(entry.upgrade_selected).to be true
    # Upgraded quantity, which only holds if the upgrade was applied *before* the companions synced.
    expect(result.list.list_entries.where.not(companion_of_entry_id: nil).count).to eq(4)
  end

  # Apprentice Doctor's mentor may be named before it has been created — she can sit above her
  # Doctor in the list — which is the whole reason mentors are wired in a second pass.
  it "links a mentor named before it appears" do
    model!("Doctor")
    apprentice = create(:profile, name: "Apprentice Doctor", faction: "guild")
    apprentice.replace_spell_pools!([ { of: 1, slot_count: 0, grants_cantrip: true, mentor_derived: true, disciplines: [] } ])
    create(:card_reference, profile: apprentice, identifier: "guild-apprentice-a")

    result = described_class.call(text("- Apprentice Doctor\n  Mentor: Doctor\n- Doctor"), owner: user)

    entry = result.list.list_entries.find { |e| e.profile&.name == "Apprentice Doctor" }
    expect(entry.mentored_by_entry&.profile&.name).to eq("Doctor")
    expect(result.warnings).to be_empty
  end

  it "reports a mentor that is not in the gang" do
    apprentice = create(:profile, name: "Apprentice Doctor", faction: "guild")
    create(:card_reference, profile: apprentice, identifier: "guild-apprentice-a")

    result = described_class.call(text("- Apprentice Doctor\n  Mentor: Absent Doctor"), owner: user)

    expect(result.warnings).to include(a_string_matching(/unknown mentor 'Absent Doctor'/))
  end

  # Import applies what the text says and lets the usual validation judge it, so an over-budget or
  # illegal gang arrives flagged exactly as a hand-built one would be — not silently corrected.
  it "leaves roster legality to the normal validation" do
    model!("Bravo")

    result = described_class.call(text("- Bravo", header: "Carnevale gang: Tiny\nFaction: guild\nDucats: 1"), owner: user)

    expect(result.list.points).to eq(1)
    expect(result.list.selection_valid).to be false
  end
end
