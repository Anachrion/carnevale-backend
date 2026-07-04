class AddDefaultToScenariosTurns < ActiveRecord::Migration[8.1]
  def change
    change_column_default :scenarios, :turns, from: nil, to: 0
  end
end
