class TightenEquipmentColumns < ActiveRecord::Migration[8.1]
  # Equipment is embedded in the /profiles and /lists payloads, where the OpenAPI contract marks
  # name, description and cost as non-nullable. A null in any of them serializes as JSON null and
  # breaks the (strict built_value) client for every user whose list carries that item. Backfill
  # any stray nulls and enforce non-null at the column level to match the contract (B-27).
  def up
    execute "UPDATE equipment SET name = '' WHERE name IS NULL"
    execute "UPDATE equipment SET cost = 0 WHERE cost IS NULL"
    execute "UPDATE equipment SET description = '' WHERE description IS NULL"

    change_column_null :equipment, :name, false
    change_column_null :equipment, :cost, false
    change_column_default :equipment, :description, from: nil, to: ""
    change_column_null :equipment, :description, false
  end

  def down
    change_column_null :equipment, :name, true
    change_column_null :equipment, :cost, true
    change_column_default :equipment, :description, from: "", to: nil
    change_column_null :equipment, :description, true
  end
end
