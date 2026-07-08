module Api
  module V1
    class CardsController < BaseController
      # Lightweight sync manifest: one row per card with its current internal_version and the
      # versioned URLs to download its front/back faces. The app diffs this against its locally
      # cached versions and downloads only the cards that changed. Public (client-key only),
      # like the other catalog endpoints. Card stats come from /api/v1/profiles separately.
      def manifest
        scope = Catalog::CardReference.includes(:profile)
        scope = scope.where(profiles: { faction: params[:faction] }).references(:profile) if params[:faction].present?
        return unless stale?(scope, public: true)

        expires_in 1.hour, public: true
        render json: { cards: scope.map { |cr| card_json(cr) } }
      end

      private

      def card_json(cr)
        urls = cr.image_urls
        {
          identifier: cr.identifier,
          faction: cr.faction,
          internal_version: cr.internal_version,
          front_url: urls[:front_url],
          back_url: urls[:back_url],
          front_bytes: byte_size(cr.front_path),
          back_bytes: byte_size(cr.back_path)
        }
      end

      def byte_size(path)
        path&.exist? ? path.size : nil
      end
    end
  end
end
