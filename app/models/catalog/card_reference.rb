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

    # A card reference is the finished card the app downloads, so it owns both its faces. Both are
    # named after the identifier — the stable slug the app already keys cards by — rather than the
    # profile's name, which is display text and can be re-worded.
    #
    # Only the front carries the illustration, so the two backs of an A/B pair hold identical
    # bytes. That duplication is deliberate: a card's faces belong to the card, not to whichever
    # of them happens to differ.
    def card_front
      "#{identifier}-front.png"
    end

    def card_back
      "#{identifier}-back.png"
    end

    # The authored illustration this card renders with (see Backoffice::ProfilesController).
    def illustration
      profile.illustrations.find_by(number: illustration_number)
    end

    def front_path
      IMAGES_DIR.join(card_front)
    end

    def back_path
      IMAGES_DIR.join(card_back)
    end

    # SHA256 of the front + back image bytes, or nil if either file is missing. Drives
    # internal_version bumps in the cards:reversion task.
    def image_digest
      return nil unless front_path.exist? && back_path.exist?

      Digest::SHA256.hexdigest(File.binread(front_path) + File.binread(back_path))
    end

    # Advance internal_version when the on-disk image bytes have changed since the recorded
    # baseline. Establishes the baseline (staying at version 1) the first time images appear.
    # Returns :missing, :baselined, :bumped, or :unchanged. Shared by the cards:reversion task
    # and the backoffice render-to-catalog action so both apply the exact same rule.
    def reversion!
      digest = image_digest
      return :missing if digest.nil?

      if content_digest.nil?
        update_columns(content_digest: digest, updated_at: Time.current)
        :baselined
      elsif content_digest != digest
        update_columns(internal_version: internal_version + 1, content_digest: digest, updated_at: Time.current)
        :bumped
      else
        :unchanged
      end
    end

    # Versioned public URLs for the app to download. The ?v= cache-buster changes with the
    # image, so intermediary caches never serve a stale face for a reused filename.
    def image_urls
      {
        front_url: "/cards/#{card_front}?v=#{internal_version}",
        back_url: "/cards/#{card_back}?v=#{internal_version}"
      }
    end
  end
end

# == Schema Information
#
# Table name: card_references
#
#  id                  :bigint           not null, primary key
#  content_digest      :string
#  identifier          :string           not null
#  illustration_number :integer          default(1), not null
#  internal_version    :integer          default(1), not null
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  profile_id          :bigint           not null
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
