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
        return unless stale?(scope)

        expires_in 1.hour
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
