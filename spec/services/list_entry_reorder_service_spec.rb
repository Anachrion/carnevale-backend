require 'rails_helper'

RSpec.describe ListEntryReorderService, type: :service do
  let(:list) { create(:list, faction: :guild, points: 500) }

  def create_entry(position)
    profile = create(:profile, faction: :guild, ducats: 10)
    ref = create(:card_reference, profile: profile)
    entry = Gang::Entry.new(list: list, entry: ref, position: position)
    entry.save(validate: false)
    entry
  end

  def ordered_positions
    list.list_entries.order(:position).pluck(:position)
  end

  def entry_at(position)
    list.list_entries.find_by!(position: position)
  end

  before do
    @e1 = create_entry(1)
    @e2 = create_entry(2)
    @e3 = create_entry(3)
    @e4 = create_entry(4)
    @e5 = create_entry(5)
  end

  it "does nothing when the position is unchanged" do
    described_class.call(@e3, 3)
    expect(ordered_positions).to eq([1, 2, 3, 4, 5])
  end

  context "moving up (lower position number)" do
    it "shifts entries between old and new position down by one" do
      described_class.call(@e4, 2)

      expect(@e4.reload.position).to eq(2)
      expect(@e2.reload.position).to eq(3)
      expect(@e3.reload.position).to eq(4)
      expect(@e1.reload.position).to eq(1)
      expect(@e5.reload.position).to eq(5)
    end

    it "maintains strict incrementality" do
      described_class.call(@e5, 1)
      expect(ordered_positions).to eq([1, 2, 3, 4, 5])
    end
  end

  context "moving down (higher position number)" do
    it "shifts entries between old and new position up by one" do
      described_class.call(@e2, 4)

      expect(@e2.reload.position).to eq(4)
      expect(@e3.reload.position).to eq(2)
      expect(@e4.reload.position).to eq(3)
      expect(@e1.reload.position).to eq(1)
      expect(@e5.reload.position).to eq(5)
    end

    it "maintains strict incrementality" do
      described_class.call(@e1, 5)
      expect(ordered_positions).to eq([1, 2, 3, 4, 5])
    end
  end

  it "clamps to 1 if given a position below the range" do
    described_class.call(@e3, 0)
    expect(@e3.reload.position).to eq(1)
    expect(ordered_positions).to eq([1, 2, 3, 4, 5])
  end

  it "clamps to the last position if given a position above the range" do
    described_class.call(@e3, 99)
    expect(@e3.reload.position).to eq(5)
    expect(ordered_positions).to eq([1, 2, 3, 4, 5])
  end
end
