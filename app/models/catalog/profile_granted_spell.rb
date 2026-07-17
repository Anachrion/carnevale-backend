module Catalog
  class ProfileGrantedSpell < ApplicationRecord
    self.table_name = "profile_granted_spells"

    GRANT_KINDS = %w[named_spell all_cantrips].freeze

    belongs_to :profile, class_name: "Catalog::Profile"
    belongs_to :spell, class_name: "Catalog::Spell", optional: true
    belongs_to :special_rule, class_name: "Catalog::SpecialRule", optional: true

    validates :grant_kind, inclusion: { in: GRANT_KINDS }
    # A named_spell grant needs *something* to name it: either a real catalog Spell (Galilean
    # Priest's Waves of Force) or the unique_spell_* fields (The Drowned Nun's Dagonite Baptism,
    # Maria Fioritura's Creative Creation — character-unique, no Discipline, never a Catalog::Spell
    # row). all_cantrips needs neither; it expands to all 5 disciplines' Cantrips at read time.
    validate :named_spell_has_a_source

    # The name/cost/difficulty/description to display, resolved from whichever source this grant
    # uses. Meaningless (nil) for an all_cantrips grant — the caller expands that to real Spells.
    def resolved_name = spell&.name || unique_spell_name
    def resolved_cost = spell&.cost || unique_spell_cost
    def resolved_difficulty = spell&.difficulty || unique_spell_difficulty
    def resolved_description = spell&.description || unique_spell_description

    private

    def named_spell_has_a_source
      return unless grant_kind == "named_spell"

      errors.add(:base, "must reference a Spell or provide a unique spell name") if spell_id.blank? && unique_spell_name.blank?
    end
  end
end

# == Schema Information
#
# Table name: profile_granted_spells
#
#  id                       :bigint           not null, primary key
#  consumes_slot            :boolean          default(FALSE), not null
#  grant_kind               :string           default("named_spell"), not null
#  position                 :integer          default(0), not null
#  resets_each_round        :boolean          default(TRUE), not null
#  unique_spell_cost        :integer
#  unique_spell_description :text
#  unique_spell_difficulty  :integer
#  unique_spell_name        :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  profile_id               :bigint           not null
#  special_rule_id          :bigint
#  spell_id                 :bigint
#
# Indexes
#
#  index_profile_granted_spells_on_profile_id       (profile_id)
#  index_profile_granted_spells_on_special_rule_id  (special_rule_id)
#  index_profile_granted_spells_on_spell_id         (spell_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (special_rule_id => special_rules.id) ON DELETE => nullify
#  fk_rails_...  (spell_id => spells.id)
#
