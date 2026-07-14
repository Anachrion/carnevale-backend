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

    # Where the authored illustrations live, keyed by faction — the same files the card view
    # draws through asset_path("illustrations/<faction>/<path>").
    ILLUSTRATIONS_DIR = Rails.root.join("app", "assets", "images", "illustrations").freeze

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
    # Picked from the loaded association so a staleness sweep over the whole catalog doesn't
    # issue a query per reference.
    def illustration
      profile.illustrations.detect { |i| i.number == illustration_number }
    end

    # The illustration's file on disk, or nil when this reference has no illustration.
    def illustration_path
      illus = illustration
      ILLUSTRATIONS_DIR.join(profile.faction, illus.path) if illus
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

    # content_digest records what we rendered; source_digest records what we rendered it *from*.
    # The two answer different questions: reversion! asks "did the image bytes change, so the app
    # must re-download?", while stale? asks "did the art or the stats change since we last
    # rendered, so the images on disk are out of date?". Without the second one, editing a profile
    # or repositioning an illustration leaves the catalog silently serving the old card.

    # Everything a render draws from: the printed stats, the weapons and special rules, the
    # illustration's framing, the illustration file's own bytes, and the shared card template.
    def source_fingerprint
      Digest::SHA256.hexdigest(JSON.generate([
        self.class.template_digest,
        profile_source,
        illustration_source
      ]))
    end

    # True when public/cards no longer matches what the backoffice would render right now —
    # including when the images are missing, or when nothing was ever recorded about them (a
    # reference rendered before source_digest existed; a full render clears that).
    def stale?
      return true unless front_path.exist? && back_path.exist?
      return true if source_digest.nil?

      source_digest != source_fingerprint
    end

    # Record the sources the images on disk were just rendered from. Called by the backoffice
    # button and by cards:render immediately after writing the faces, so stale? has a baseline.
    def stamp_source!
      update_columns(source_digest: source_fingerprint, updated_at: Time.current)
    end

    # The references whose images are out of date. Staleness is computed in Ruby (it hashes files
    # on disk), so this eager-loads everything the fingerprint reads and returns an Array.
    def self.stale
      includes(profile: [
        :illustrations,
        { profile_weapons: :weapon },
        { profile_special_rules: :special_rule }
      ]).select(&:stale?)
    end

    # The card template every profile is drawn into: change the layout, a helper, or a template
    # asset and every card on disk is out of date, whatever the profiles say. Cached against the
    # files' mtimes so sweeping the catalog doesn't re-hash the multi-megabyte motifs per card.
    def self.template_digest
      files = template_files
      stamp = files.map { |f| [ f.to_s, f.mtime ] }
      return @template_digest if @template_stamp == stamp

      @template_stamp  = stamp
      @template_digest = Digest::SHA256.hexdigest(files.map { |f| Digest::SHA256.file(f).hexdigest }.join)
    end

    def self.template_files
      [
        Rails.root.join("app", "views", "backoffice", "profiles", "card.html.erb"),
        Rails.root.join("app", "helpers", "backoffice", "profiles_helper.rb"),
        *Rails.root.glob("public/card-template/*")
      ].select(&:file?).sort
    end

    # Versioned public URLs for the app to download. The ?v= cache-buster changes with the
    # image, so intermediary caches never serve a stale face for a reused filename.
    def image_urls
      {
        front_url: "/cards/#{card_front}?v=#{internal_version}",
        back_url: "/cards/#{card_back}?v=#{internal_version}"
      }
    end

    private

    # Every profile column is printed somewhere on the card, so all of them count — as do the
    # weapons and special rules in the order they are laid out.
    def profile_source
      [
        profile.attributes.except("id", "created_at", "updated_at"),
        profile.profile_weapons.map { |pw| [ pw.position, pw.weapon.attributes.except("id", "created_at", "updated_at") ] },
        profile.profile_special_rules.map { |pr| [ pr.position, pr.special_rule.attributes.except("id", "created_at", "updated_at") ] }
      ]
    end

    # The framing (offset, zoom, flip) *and* the file's bytes: re-exporting the art without
    # touching the record has to count as a change too. A missing file hashes as nil, so it
    # reappearing is itself a change.
    def illustration_source
      illus = illustration
      return nil if illus.nil?

      path = illustration_path
      [
        illus.attributes.except("id", "created_at", "updated_at"),
        path.exist? ? Digest::SHA256.file(path).hexdigest : nil
      ]
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
#  source_digest       :string
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
