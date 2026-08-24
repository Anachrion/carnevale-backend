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
    # A player's collection of miniatures (CARNEVALEB-76): what they own, and how far along each
    # model is. Read whole, written one profile at a time or in bulk.
    #
    # Both writes are PUTs of *absolute* counts, never increments, so they are idempotent by
    # construction: the client's automatic retry of a mutation it never saw the answer to replays
    # the same target state rather than stepping a counter twice. That is why there is no
    # Idempotency-Key here, unlike the additive hire/summon endpoints.
    class CollectionController < BaseController
      before_action :authenticate_user!

      def index
        render json: current_user.collection_items.order(:profile_id).map { |item| item_json(item) }
      end

      # PUT /api/v1/collection/:profile_id — a partial body is deliberate: the app sends the one
      # count a stepper moved and lets the model settle the other two around it.
      def update
        item = Collection::Item.set!(
          user: current_user,
          profile_id: params[:profile_id],
          counts: counts_params
        )
        render json: item_json(item)
      end

      # PUT /api/v1/collection — several profiles at once, for the Collection screen's bulk actions.
      # All or nothing: a body that names an unknown profile changes none of the others, so the
      # client never has to work out how far a half-applied batch got.
      def bulk_update
        items = ActiveRecord::Base.transaction do
          bulk_params.map do |entry|
            Collection::Item.set!(
              user: current_user,
              profile_id: entry[:profile_id],
              counts: entry
            )
          end
        end
        render json: items.map { |item| item_json(item) }
      end

      private

      def counts_params
        params.require(:item).permit(*Collection::Item::COUNTS).to_h.symbolize_keys
      end

      def bulk_params
        params.require(:items).map do |entry|
          entry.permit(:profile_id, *Collection::Item::COUNTS).to_h.symbolize_keys
        end
      end

      # A destroyed row (every count back to zero) still renders its zeros, so the client can
      # reconcile the profile it just edited without a second request.
      def item_json(item)
        {
          profile_id: item.profile_id,
          owned: item.owned,
          built: item.built,
          painted: item.painted
        }
      end
    end
  end
end
