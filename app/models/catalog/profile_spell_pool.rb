module Catalog
  class ProfileSpellPool < ApplicationRecord
    self.table_name = "profile_spell_pools"

    belongs_to :profile, class_name: "Catalog::Profile"
    belongs_to :special_rule, class_name: "Catalog::SpecialRule", optional: true
    has_many :profile_spell_pool_disciplines, -> { order(:discipline) },
      class_name: "Catalog::ProfileSpellPoolDiscipline", foreign_key: "pool_id", dependent: :destroy

    validates :of, numericality: { only_integer: true, greater_than: 0 }
    validates :slot_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # The eligible-disciplines slugs for this pool, e.g. ["blood_rites", "fateweaving"].
    def disciplines
      profile_spell_pool_disciplines.map(&:discipline)
    end
  end
end

# == Schema Information
#
# Table name: profile_spell_pools
#
#  id                        :bigint           not null, primary key
#  distinct_from_other_pools :boolean          default(FALSE), not null
#  grants_cantrip            :boolean          default(TRUE), not null
#  mage_slot_count           :integer          default(0), not null
#  mentor_derived            :boolean          default(FALSE), not null
#  of                        :integer          default(1), not null
#  position                  :integer          default(0), not null
#  resets_each_round         :boolean          default(TRUE), not null
#  slot_count                :integer          default(0), not null
#  unlimited                 :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  profile_id                :bigint           not null
#  special_rule_id           :bigint
#
# Indexes
#
#  index_profile_spell_pools_on_profile_id       (profile_id)
#  index_profile_spell_pools_on_special_rule_id  (special_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (special_rule_id => special_rules.id) ON DELETE => nullify
#
