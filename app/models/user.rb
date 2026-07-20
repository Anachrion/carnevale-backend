# Copyright 2026 Anachrion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # Devise builds `conditions` from the login param (still keyed `:email` — authentication_keys is
  # left at its default) and hands it here. Override the lookup so that value can match either the
  # email or the username column, letting a user sign in with whichever one they remember.
  def self.find_for_database_authentication(conditions)
    login = conditions[:email].to_s.strip.downcase
    where("lower(email) = :login OR lower(username) = :login", login: login).first
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
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
