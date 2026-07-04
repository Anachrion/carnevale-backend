class AddTurnsToScenarios < ActiveRecord::Migration[8.1]
  def up
    add_column :scenarios, :turns, :integer

    execute <<~SQL
      UPDATE scenarios SET turns = (regexp_match(duration, '\\A(\\d+)'))[1]::integer
      WHERE duration ~ '\\A\\d+'
    SQL

    change_column_null :scenarios, :turns, false, 0
  end

  def down
    remove_column :scenarios, :turns
  end
end
