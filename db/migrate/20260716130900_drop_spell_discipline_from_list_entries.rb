class DropSpellDisciplineFromListEntries < ActiveRecord::Migration[8.1]
  # `entry_spells.pool_id` deliberately stays nullable at the DB level rather than NOT NULL here:
  # tightening it would require this migration to run strictly after the one-time exception-profile
  # pool setup (a rake task, not a migration, so ordering isn't guaranteed) without ever having a
  # window where an in-flight request could violate it. `Gang::EntrySpell` enforces "always present"
  # at the model layer instead.
  def up
    remove_column :list_entries, :spell_discipline
  end

  def down
    add_column :list_entries, :spell_discipline, :string
  end
end
