class AddDucatsToScenarios < ActiveRecord::Migration[8.1]
  def change
    add_column :scenarios, :ducats, :integer, null: false, default: 0
  end
end
