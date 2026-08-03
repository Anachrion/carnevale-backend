# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

module Catalog
  class Illustration < ApplicationRecord
    belongs_to :profile, class_name: "Catalog::Profile"

    # The card art. Two sources: an uploaded file (Active Storage), or the committed asset named by
    # `path` under app/assets/images/illustrations/<faction>/ — how the ~375 seeded profiles carry
    # their art. An upload wins over the committed file when both are present.
    has_one_attached :image

    # The upload form's `accept=` is client-side only; enforce the real thing so a non-image or an
    # oversized file can't be stored and then drawn onto (and published as) a card (B-22).
    validates :image, content_type: %w[image/png image/jpeg image/webp],
                      size: { less_than: 10.megabytes }

    # One or the other must identify the art: a committed asset name, or an uploaded image. (The
    # path column is NOT NULL, so an upload-only illustration stores "" — see the upload action.)
    validates :path, presence: true, unless: -> { image.attached? }
    validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :number, uniqueness: { scope: :profile_id }

    def image_attached?
      image.attached?
    end

    # A fingerprint of the art itself for CardReference's staleness digest: the uploaded blob's
    # checksum when there is one, else nil (a committed file is hashed separately, by its bytes,
    # since the model holds only its name). Changes whenever the uploaded art is replaced.
    def source_key
      image.attached? ? image.blob.checksum : nil
    end
  end
end

# == Schema Information
#
# Table name: illustrations
#
#  id         :bigint           not null, primary key
#  flipped    :boolean          default(FALSE), not null
#  number     :integer          default(1), not null
#  offset_x   :integer          default(0), not null
#  offset_y   :integer          default(0), not null
#  path       :string           not null
#  zoom       :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#
# Indexes
#
#  index_illustrations_on_profile_id             (profile_id)
#  index_illustrations_on_profile_id_and_number  (profile_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
