class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    # Backoffice (card-authoring) access. App users sign up via the API and stay false;
    # only admins may reach /backoffice. See Backoffice::BaseController.
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
