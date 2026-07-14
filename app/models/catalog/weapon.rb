module Catalog
  class Weapon < ApplicationRecord
    include StringListColumns

    has_many :profile_weapons, class_name: "Catalog::ProfileWeapon"
    has_many :profiles, through: :profile_weapons

    # Damage, evasion and penetration all go negative somewhere in the catalog (penetration on a
    # third of the weapons), so only integer-ness is asserted here, never sign.
    validates :name, presence: true
    validates :damage, :evasion, :penetration, :range, numericality: { only_integer: true }
    validates_string_list :abilities

    # A weapon is shared, so editing one is a catalog-wide edit: every profile carrying it prints
    # it. Nothing re-renders automatically, but a card's source fingerprint covers its weapons, so
    # all of these turn up in the render queue as out of date the moment this record changes.
    def cards_affected
      Catalog::CardReference.where(profile_id: profile_weapons.select(:profile_id))
    end
  end
end

# == Schema Information
#
# Table name: weapons
#
#  id          :bigint           not null, primary key
#  abilities   :json             not null
#  damage      :integer          default(0), not null
#  evasion     :integer          default(0), not null
#  name        :string           not null
#  penetration :integer          default(0), not null
#  range       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
