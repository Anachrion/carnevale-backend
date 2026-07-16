require 'rails_helper'

RSpec.describe Catalog::Equipment, type: :model do
  it "is valid with a name and a non-negative cost" do
    expect(build(:equipment, name: "Gondola", cost: 10)).to be_valid
  end

  it "requires a name" do
    equipment = build(:equipment, name: nil)
    expect(equipment).not_to be_valid
    expect(equipment.errors[:name]).to be_present
  end

  it "requires a cost" do
    equipment = build(:equipment, cost: nil)
    expect(equipment).not_to be_valid
    expect(equipment.errors[:cost]).to be_present
  end

  it "rejects a negative cost" do
    equipment = build(:equipment, cost: -1)
    expect(equipment).not_to be_valid
    expect(equipment.errors[:cost]).to be_present
  end
end

# == Schema Information
#
# Table name: equipment
#
#  id          :bigint           not null, primary key
#  cost        :integer
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
