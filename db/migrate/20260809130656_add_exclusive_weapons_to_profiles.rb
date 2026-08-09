# Some models are printed with an "OR" band between their weapons (the Guild's Fisherman, and its
# Pole Spear & Net or Harpoon Gun): the player picks one of them when the model is deployed, rather
# than carrying both. This says the profile's weapons are that kind of list.
#
# Profile-level rather than a flag on each profile_weapons row, because every model that does this
# carries exactly two weapons and chooses between them — no profile in the catalog mixes a fixed
# weapon with a choice. Should one ever appear, the flag moves down to the join row.
class AddExclusiveWeaponsToProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :profiles, :exclusive_weapons, :boolean, default: false, null: false
  end
end
