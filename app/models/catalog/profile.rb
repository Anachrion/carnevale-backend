module Catalog
  class Profile < ApplicationRecord
    include HasFaction

    has_many :card_references, -> { order(:identifier) }, class_name: "Catalog::CardReference"

    has_many :illustrations, -> { order(:number) }, class_name: "Catalog::Illustration"

    has_many :profile_weapons, -> { order(:position) }, class_name: "Catalog::ProfileWeapon"
    has_many :weapons, through: :profile_weapons

    has_many :profile_special_rules, -> { order(:position) }, class_name: "Catalog::ProfileSpecialRule"
    has_many :special_rules, through: :profile_special_rules

    # The stats printed on the card. Everything here is a small non-negative integer, and the
    # backoffice editor is now a way to get bad values into the catalog, so they are checked.
    STATS = %i[
      ducats movement attack dexterity protection mind
      action_points will_points command_points life_points size
    ].freeze

    validates :name, presence: true
    validates :faction, presence: true
    validates(*STATS, numericality: { only_integer: true, greater_than_or_equal_to: 0 })
    validate :abilities_and_keywords_are_lists_of_strings

    MAGE_ABILITY = /\AMage \((\d+)\)\z/
    EXPERT_SORCERER_ABILITY = /\AExpert Sorcerer \((\d+)\)\z/
    DISCIPLINE_KEYWORD = /\ADiscipline \((.+)\)\z/

    # X from the "Mage (X)" ability, or nil if this profile is not a Mage. This is the number of
    # (non-Cantrip) spells the model may know before Expert Sorcerer bonuses (rulebook p24).
    def mage_level
      abilities.filter_map { |a| a[MAGE_ABILITY, 1]&.to_i }.first
    end

    def mage?
      mage_level.present?
    end

    # X from the "Expert Sorcerer (X)" ability, added to the number of spells known; 0 if absent.
    def expert_sorcerer_level
      abilities.filter_map { |a| a[EXPERT_SORCERER_ABILITY, 1]&.to_i }.first || 0
    end

    # Maximum number of non-Cantrip spells this model may know. Cantrips are always known for free
    # and do not count towards this total.
    def spell_slots
      return 0 unless mage?

      mage_level + expert_sorcerer_level
    end

    # Discipline slugs this model may pick spells from, parsed from the "Discipline (A, B)" keyword
    # (e.g. "Discipline (Blood Rites, Divinity)" => ["blood_rites", "divinity"]). Empty if none.
    def disciplines
      keyword = keywords.grep(DISCIPLINE_KEYWORD).first
      return [] unless keyword

      keyword[DISCIPLINE_KEYWORD, 1].split(",").map { |name| name.strip.parameterize(separator: "_") }
    end

    # Weapons and special rules are shared records — one "Stiletto" row, referenced by every
    # profile that carries it — so a profile owns only its *claim* on them, held in the join rows
    # along with the order the card prints them in. Replacing the list therefore rewrites those
    # join rows; the weapon itself is never touched, and no other profile is affected.
    #
    # A nil list means the form said nothing about them (Grover's card fetch, for one), so the
    # current list stands.
    def replace_weapons!(ids)
      replace_join!(profile_weapons, :weapon_id, ids)
    end

    def replace_special_rules!(ids)
      replace_join!(profile_special_rules, :special_rule_id, ids)
    end

    # Draw these instead of what the database holds, without writing anything — the editor's live
    # preview renders a card that has not been saved (and may never be).
    def preview_weapons(ids)
      preview_association(:weapons, Catalog::Weapon, ids)
    end

    def preview_special_rules(ids)
      preview_association(:special_rules, Catalog::SpecialRule, ids)
    end

    private

    def replace_join!(collection, foreign_key, ids)
      return if ids.nil?

      transaction do
        collection.destroy_all
        ids.each_with_index { |id, index| collection.create!(foreign_key => id, :position => index + 1) }
      end
    end

    # Ordered by the ids as given: the list's order *is* the print order.
    def preview_association(name, klass, ids)
      return if ids.nil?

      by_id = klass.where(id: ids).index_by(&:id)
      association(name).target = ids.filter_map { |id| by_id[id] }
      association(name).loaded!
    end

    # These are json columns, so the database will happily take a string or a nested hash. Every
    # reader — the card view, mage_level, disciplines — assumes a flat list of strings.
    def abilities_and_keywords_are_lists_of_strings
      { abilities: abilities, keywords: keywords }.each do |attribute, value|
        next if value.is_a?(Array) && value.all?(String)

        errors.add(attribute, "must be a list of strings")
      end
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id             :bigint           not null, primary key
#  abilities      :json             not null
#  action_points  :integer          default(0), not null
#  attack         :integer          default(0), not null
#  command_points :integer          default(0), not null
#  dexterity      :integer          default(0), not null
#  ducats         :integer          default(0), not null
#  faction        :string           default(NULL), not null
#  keywords       :json             not null
#  life_points    :integer          default(0), not null
#  mind           :integer          default(0), not null
#  movement       :integer          default(0), not null
#  name           :string           default(""), not null
#  protection     :integer          default(0), not null
#  size           :integer          default(0), not null
#  version        :string           default("2.2.0"), not null
#  will_points    :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
