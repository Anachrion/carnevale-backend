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
