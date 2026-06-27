class MakeProfileRequiredOnCardReferences < ActiveRecord::Migration[8.1]
  def change
    change_column_null :card_references, :profile_id, false
  end
end
