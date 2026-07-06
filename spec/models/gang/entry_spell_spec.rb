require 'rails_helper'

RSpec.describe Gang::EntrySpell, type: :model do
  # Regression: deleting a game tears down each player's snapshot list, cascading through entries to
  # their entry_spells. The after_commit selection-validity refresh fires on each destroyed
  # entry_spell *after* its parent entry is already gone, so reaching the list through it must
  # no-op rather than raise `undefined method 'list' for nil` (which 500'd the delete even though
  # the game itself was removed).
  it "no-ops the selection-validity refresh when its entry is already gone" do
    list = create(:list, faction: :guild, points: 100)
    profile = create(:profile, faction: :guild, ducats: 20,
                     abilities: [ "Mage (2)" ], keywords: [ "Discipline (Blood Rites)" ])
    ref = create(:card_reference, profile: profile)
    entry = create(:list_entry, list: list, entry: ref, position: 1)
    entry_spell = entry.entry_spells.create!(spell: create(:spell, discipline: :blood_rites))

    # Mimic the mid-cascade state: the entry_spell and its parent entry rows are both gone (as the
    # list teardown removes them), and the belongs_to reloads to nil on the destroyed instance.
    entry_spell.destroy!
    entry.delete
    entry_spell.association(:list_entry).reset

    expect { entry_spell.send(:refresh_list_selection_validity) }.not_to raise_error
  end
end
