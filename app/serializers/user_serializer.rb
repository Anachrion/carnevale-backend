# SPDX-License-Identifier: AGPL-3.0-or-later

class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      email: @user.email,
      username: @user.username,
      # The two Collection switches (CARNEVALEB-76): whether the feature is live, and whether it
      # is offered in the menus at all. They ride in the user payload rather than behind their own
      # endpoint so the app knows at sign-in, before any screen that depends on them is built.
      collection_enabled: @user.collection_enabled,
      collection_visible: @user.collection_visible
    }
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  collection_enabled     :boolean          default(FALSE), not null
#  collection_visible     :boolean          default(TRUE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
