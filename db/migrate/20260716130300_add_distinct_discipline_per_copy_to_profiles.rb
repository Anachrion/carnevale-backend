class AddDistinctDisciplinePerCopyToProfiles < ActiveRecord::Migration[8.1]
  def change
    # Romani's Tarot: when a gang fields more than one copy of this profile, each copy must commit to
    # a different Discipline from every other copy. True only for Romani today.
    add_column :profiles, :distinct_discipline_per_copy, :boolean, null: false, default: false
  end
end
