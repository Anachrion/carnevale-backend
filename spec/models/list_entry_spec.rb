require 'rails_helper'

RSpec.describe ListEntry, type: :model do
  let(:list) { create(:list, faction: :guild, points: 100) }

  def guild_ref(cost: 10, keywords: [])
    profile = create(:profile, faction: :guild, ducats: cost, keywords: keywords)
    create(:card_reference, profile: profile)
  end

  describe "on create" do
    it "is valid with a matching faction and enough points" do
      entry = list.list_entries.build(entry: guild_ref, position: 1)
      expect(entry).to be_valid
    end

    it "still saves when the card pushes the list over budget, but marks the list's selection invalid" do
      entry = create(:list_entry, list: list, entry: guild_ref(cost: 101), position: 1)

      expect(entry).to be_persisted
      expect(list.reload.selection_valid).to be false
      expect(list.selection_errors).to include(match(/exceeds the 100 points limit/))
    end

    it "still saves when the card belongs to a different faction, but marks the list's selection invalid" do
      profile = create(:profile, faction: :rashaar, ducats: 10)
      ref = create(:card_reference, profile: profile)
      entry = create(:list_entry, list: list, entry: ref, position: 1)

      expect(entry).to be_persisted
      expect(list.reload.selection_valid).to be false
      expect(list.selection_errors).to include(match(/rashaar/))
    end

    it "still saves when adding a duplicate Unique card, but marks the list's selection invalid" do
      ref = guild_ref(keywords: ["Unique", "Leader"])
      create(:list_entry, list: list, entry: ref, position: 1)

      duplicate = create(:list_entry, list: list, entry: ref, position: 2)

      expect(duplicate).to be_persisted
      expect(list.reload.selection_valid).to be false
      expect(list.selection_errors).to include(match(/Unique and can only be hired once/))
    end

    it "marks the list's selection valid once the entries satisfy the rules" do
      create(:list_entry, list: list, entry: guild_ref(keywords: ["Leader"]), position: 1)

      expect(list.reload.selection_valid).to be true
      expect(list.selection_errors).to eq([])
    end
  end

  describe "on update" do
    it "refreshes the list's selection validity" do
      ref = guild_ref(keywords: ["Leader"])
      entry = create(:list_entry, list: list, entry: ref, position: 1)
      expect(list.reload.selection_valid).to be true

      ref.profile.update!(ducats: 200)
      entry.touch

      expect(list.reload.selection_valid).to be false
    end
  end

  describe "on destroy" do
    it "refreshes the list's selection validity" do
      leader = guild_ref(keywords: ["Leader"])
      henchman = guild_ref(keywords: ["Henchman"])
      hero_a = guild_ref(keywords: ["Hero"])
      hero_b = guild_ref(keywords: ["Hero"])
      create(:list_entry, list: list, entry: leader, position: 1)
      create(:list_entry, list: list, entry: henchman, position: 2)
      extra_hero = create(:list_entry, list: list, entry: hero_a, position: 3)
      create(:list_entry, list: list, entry: hero_b, position: 4)

      expect(list.reload.selection_valid).to be false

      extra_hero.destroy

      expect(list.reload.selection_valid).to be true
    end
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id         :bigint           not null, primary key
#  entry_type :string           not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :bigint           not null
#  list_id    :bigint           not null
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#
