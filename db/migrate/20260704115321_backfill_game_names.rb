class BackfillGameNames < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE games SET name = scenarios.name
      FROM scenarios WHERE scenarios.id = games.scenario_id AND games.name IS NULL
    SQL

    change_column_null :games, :name, false
  end

  def down
    change_column_null :games, :name, true
  end
end
