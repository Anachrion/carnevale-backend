class AddAsymmetricToScenarios < ActiveRecord::Migration[8.1]
  def change
    add_column :scenarios, :asymmetric, :boolean, null: false, default: false
  end
end
