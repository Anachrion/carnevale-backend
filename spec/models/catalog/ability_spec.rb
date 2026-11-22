# SPDX-License-Identifier: AGPL-3.0-or-later

require "rails_helper"

RSpec.describe Catalog::Ability do
  describe ".base_name" do
    it "strips a trailing rating" do
      expect(described_class.base_name("Acrobatic (2)")).to eq("Acrobatic")
    end

    it "leaves a multi-word name that carries no rating alone" do
      expect(described_class.base_name("Water Creature")).to eq("Water Creature")
    end
  end

  describe ".keyword_pattern" do
    it "matches an ability named in prose, together with its rating" do
      create(:ability, name: "Acrobatic")

      expect("Gain Acrobatic (2) this turn"[described_class.keyword_pattern]).to eq("Acrobatic (2)")
    end

    it "matches an ability carrying no rating" do
      create(:ability, name: "Boat Crew")

      expect("This character has Boat Crew."[described_class.keyword_pattern]).to eq("Boat Crew")
    end

    it "picks up an ability added to the catalog, without a code change" do
      create(:ability, name: "Tide Walker")

      expect("Gain Tide Walker (1)"[described_class.keyword_pattern]).to eq("Tide Walker (1)")
    end

    it "does not match a longer word that merely starts with an ability's name" do
      create(:ability, name: "Fear")

      expect("The Fearless captain"[described_class.keyword_pattern]).to be_nil
    end

    # An alternation stops at its first hit, so a short name listed ahead of a longer one it
    # prefixes would bold only its own half.
    it "prefers the longest ability when one name prefixes another" do
      create(:ability, name: "Expert")
      create(:ability, name: "Expert Offence")

      expect("Gain Expert Offence (2)"[described_class.keyword_pattern]).to eq("Expert Offence (2)")
    end

    # Parentheses cannot be part of a glossary name (they would read as a rating, which base_name
    # strips), so the punctuation here is the kind a name can hold: "." and "+".
    it "treats a name containing regex punctuation literally" do
      create(:ability, name: "Snap.Shot+")

      expect("Gain Snap.Shot+ (2)"[described_class.keyword_pattern]).to eq("Snap.Shot+ (2)")
      expect("SnapxShott"[described_class.keyword_pattern]).to be_nil
    end

    it "matches the same name only once when both categories define it" do
      create(:ability, name: "Poisoned", category: "character")
      create(:ability, name: "Poisoned", category: "weapon")

      expect(described_class.keyword_pattern.source.scan("Poisoned").size).to eq(1)
    end

    it "matches nothing rather than everything when the glossary is empty" do
      expect(described_class.count).to eq(0)

      expect("Gain Acrobatic (2)"[described_class.keyword_pattern]).to be_nil
    end
  end

  describe "validation" do
    it "stores the name without surrounding spaces, so cards can match it" do
      create(:ability, name: "  Tide Walker ")
      profile = build(:profile, abilities: [ "Tide Walker (1)" ])

      expect(described_class.known_names("character")).to include("Tide Walker")
      expect(profile).to be_valid
    end

    it "rejects a name carrying a rating, which belongs on the card" do
      ability = build(:ability, name: "Acrobatic (2)")

      expect(ability).not_to be_valid
      expect(ability.errors[:name].join).to include("rating")
    end
  end
end

# == Schema Information
#
# Table name: abilities
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :text             default(""), not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_abilities_on_category_and_name  (category,name) UNIQUE
#
