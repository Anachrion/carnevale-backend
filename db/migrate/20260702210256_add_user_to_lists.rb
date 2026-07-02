class AddUserToLists < ActiveRecord::Migration[8.1]
  def up
    add_reference :lists, :user, null: true, foreign_key: true

    fallback_user_id = User.order(:id).first&.id
    execute("UPDATE lists SET user_id = #{fallback_user_id}") if fallback_user_id

    change_column_null :lists, :user_id, false
  end

  def down
    remove_reference :lists, :user, foreign_key: true
  end
end
