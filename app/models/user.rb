# SPDX-License-Identifier: AGPL-3.0-or-later

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :lists, as: :owner, class_name: "Gang::List", dependent: :destroy
  has_many :game_players, class_name: "Encounter::Player", dependent: :destroy
  has_many :games, through: :game_players
  has_many :refresh_tokens, dependent: :delete_all
  # The player's physical collection: which models they own, and how far along each one is
  # (CARNEVALEB-76). Keyed per catalog profile; see Collection::Item.
  has_many :collection_items, class_name: "Collection::Item", dependent: :delete_all

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # Devise builds `conditions` from the login param (still keyed `:email` — authentication_keys is
  # left at its default) and hands it here. Override the lookup so that value can match either the
  # email or the username column, letting a user sign in with whichever one they remember.
  def self.find_for_database_authentication(conditions)
    login = conditions[:email].to_s.strip.downcase
    where("lower(email) = :login OR lower(username) = :login", login: login).first
  end

  private

  # Enqueue Devise emails (reset-password instructions, password-change notices) as background jobs
  # instead of blocking the request while SMTP delivers. This dispatches ActionMailer's built-in
  # delivery job, which runs on Solid Queue in production.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
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
