require 'rails_helper'

RSpec.describe ListSortingService, type: :service do
  let(:list) { create(:list, faction: :guild, points: 500) }

  def entry_with(keywords:, cost:, position:)
    profile = create(:profile, faction: :guild, keywords: keywords, ducats: cost)
    ref = create(:card_reference, profile: profile)
    entry = ListEntry.new(list: list, entry: ref, position: position)
    entry.save(validate: false)
    entry
  end

  def positions_by_name
    list.list_entries.includes(entry: :profile).order(:position).map do |e|
      e.entry.profile.name
    end
  end

  describe ".call" do
    it "puts leaders before heroes before henchmen" do
      entry_with(keywords: ["Henchman"], cost: 10, position: 1)
      entry_with(keywords: ["Hero"],     cost: 10, position: 2)
      entry_with(keywords: ["Leader"],   cost: 10, position: 3)

      described_class.call(list)

      keywords_in_order = list.list_entries.includes(entry: :profile).order(:position).map do |e|
        e.entry.profile.keywords.first
      end
      expect(keywords_in_order).to eq(%w[Leader Hero Henchman])
    end

    it "sorts by cost within the same role" do
      entry_with(keywords: ["Hero"], cost: 30, position: 1)
      entry_with(keywords: ["Hero"], cost: 10, position: 2)
      entry_with(keywords: ["Hero"], cost: 20, position: 3)

      described_class.call(list)

      costs_in_order = list.list_entries.includes(entry: :profile).order(:position).map do |e|
        e.entry.cost
      end
      expect(costs_in_order).to eq([10, 20, 30])
    end

    it "ranks by cost across the full sorted order" do
      entry_with(keywords: ["Henchman"], cost: 5,  position: 1)
      entry_with(keywords: ["Leader"],   cost: 30, position: 2)
      entry_with(keywords: ["Hero"],     cost: 20, position: 3)
      entry_with(keywords: ["Leader"],   cost: 10, position: 4)

      described_class.call(list)

      keywords_in_order = list.list_entries.includes(entry: :profile).order(:position).map do |e|
        e.entry.profile.keywords.first
      end
      expect(keywords_in_order).to eq(%w[Leader Leader Hero Henchman])

      costs_in_order = list.list_entries.includes(entry: :profile).order(:position).map do |e|
        e.entry.cost
      end
      expect(costs_in_order).to eq([10, 30, 20, 5])
    end

    it "reassigns positions starting from 1" do
      entry_with(keywords: ["Henchman"], cost: 10, position: 5)
      entry_with(keywords: ["Leader"],   cost: 10, position: 8)

      described_class.call(list)

      expect(list.list_entries.order(:position).pluck(:position)).to eq([1, 2])
    end

    it "treats a card with both Leader and Hero keywords as a Leader" do
      entry_with(keywords: ["Hero"],          cost: 10, position: 1)
      entry_with(keywords: ["Leader", "Hero"], cost: 10, position: 2)

      described_class.call(list)

      keywords_in_order = list.list_entries.includes(entry: :profile).order(:position).map do |e|
        e.entry.profile.keywords
      end
      expect(keywords_in_order.first).to include("Leader")
    end
  end
end
