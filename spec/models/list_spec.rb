require 'rails_helper'

RSpec.describe Gang::List, type: :model do
  def guild_ref(cost: 10, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  describe "#snapshot_for" do
    it "deep-copies the list and its entries under the new owner" do
      list = create(:list, faction: :guild, points: 100)
      create(:list_entry, list: list, entry: guild_ref, position: 1)
      game_player = create(:game_player)

      snapshot = list.snapshot_for(game_player)

      expect(snapshot).not_to eq(list)
      expect(snapshot.owner).to eq(game_player)
      expect(snapshot.name).to eq(list.name)
      expect(snapshot.list_entries.count).to eq(1)
      expect(snapshot.list_entries.first.entry).to eq(list.list_entries.first.entry)
    end

    it "copies each Mage's committed Discipline and known spells" do
      list = create(:list, faction: :guild, points: 100)
      profile = create(:profile, faction: :guild, ducats: 20,
                       abilities: ["Mage (2)"], keywords: ["Discipline (Blood Rites)"])
      ref = create(:card_reference, profile: profile)
      entry = create(:list_entry, list: list, entry: ref, position: 1)
      entry.update!(spell_discipline: "blood_rites")
      spells = create_list(:spell, 2, discipline: :blood_rites)
      spells.each { |s| entry.entry_spells.create!(spell: s) }
      game_player = create(:game_player)

      snapshot = list.snapshot_for(game_player)

      copied = snapshot.list_entries.first
      expect(copied.spell_discipline).to eq("blood_rites")
      expect(copied.spells.map(&:id)).to match_array(spells.map(&:id))
    end

    it "stays unaffected by later edits to the original list" do
      list = create(:list, faction: :guild, points: 100)
      create(:list_entry, list: list, entry: guild_ref, position: 1)
      game_player = create(:game_player)

      snapshot = list.snapshot_for(game_player)
      list.list_entries.create!(entry: guild_ref, position: 2)
      list.update!(name: "Renamed after the match")

      expect(snapshot.list_entries.reload.count).to eq(1)
      expect(snapshot.reload.name).not_to eq("Renamed after the match")
    end
  end
end

# == Schema Information
#
# Table name: lists
#
#  id               :bigint           not null, primary key
#  faction          :string           not null
#  name             :string
#  owner_type       :string           not null
#  points           :integer          default(100), not null
#  selection_errors :json             not null
#  selection_valid  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  owner_id         :bigint           not null
#
# Indexes
#
#  index_lists_on_owner  (owner_type,owner_id)
#
