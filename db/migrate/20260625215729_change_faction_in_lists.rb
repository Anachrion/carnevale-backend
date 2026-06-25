class ChangeFactionInLists < ActiveRecord::Migration[8.1]
  def change
    change_column_null :lists, :faction, false
  end
end
