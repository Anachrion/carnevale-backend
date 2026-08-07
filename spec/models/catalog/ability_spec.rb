# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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

    it "treats a name containing regex punctuation literally" do
      create(:ability, name: "Point-Blank (Heavy)")

      expect("Gain Point-Blank (Heavy)"[described_class.keyword_pattern]).to eq("Point-Blank (Heavy)")
      expect("Point!Blank xHeavyx"[described_class.keyword_pattern]).to be_nil
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
end
