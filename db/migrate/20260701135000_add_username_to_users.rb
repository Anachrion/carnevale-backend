# frozen_string_literal: true

class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :username, :string
    User.reset_column_information
    User.find_each { |user| user.update_column(:username, user.email.split("@").first) }
    change_column_null :users, :username, false
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
  end
end
