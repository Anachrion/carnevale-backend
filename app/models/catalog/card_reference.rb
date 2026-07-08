module Catalog
  class CardReference < ApplicationRecord
    belongs_to :profile, class_name: "Catalog::Profile"

    delegate :faction, to: :profile, allow_nil: true

    def cost
      profile&.ducats
    end

    validates :name, presence: true
    validates :identifier, presence: true, uniqueness: true

    # Directory holding the committed card images, served statically from /cards.
    IMAGES_DIR = Rails.root.join("public", "cards").freeze

    def front_path
      card_front.present? ? IMAGES_DIR.join(card_front) : nil
    end

    def back_path
      card_back.present? ? IMAGES_DIR.join(card_back) : nil
    end

    # SHA256 of the front + back image bytes, or nil if either file is missing. Drives
    # internal_version bumps in the cards:reversion task.
    def image_digest
      return nil unless front_path&.exist? && back_path&.exist?

      Digest::SHA256.hexdigest(File.binread(front_path) + File.binread(back_path))
    end

    # Versioned public URLs for the app to download. The ?v= cache-buster changes with the
    # image, so intermediary caches never serve a stale face for a reused filename.
    def image_urls
      {
        front_url: card_front.present? ? "/cards/#{card_front}?v=#{internal_version}" : nil,
        back_url: card_back.present? ? "/cards/#{card_back}?v=#{internal_version}" : nil
      }
    end
  end
end

# == Schema Information
#
# Table name: card_references
#
#  id               :bigint           not null, primary key
#  card_back        :string
#  card_front       :string
#  content_digest   :string
#  identifier       :string           not null
#  internal_version :integer          default(1), not null
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  profile_id       :bigint           not null
#
# Indexes
#
#  index_card_references_on_identifier  (identifier) UNIQUE
#  index_card_references_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
