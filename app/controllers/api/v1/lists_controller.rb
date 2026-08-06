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
    class ListsController < BaseController
      before_action :authenticate_user!
      before_action :set_list, only: %i[show update destroy export]

      def index
        # No eager loading here: ListSerializer loads each list's entries with exactly the
        # associations it needs (incl. the card-reference profiles), so any preload here would just
        # be re-queried and thrown away (B-P2-10). The cantrip lookup is built once and shared across
        # every list rather than rebuilt per list (B-P2-3).
        cantrips = Catalog::Spell.cantrips.index_by(&:discipline)
        render json: current_user.lists.map { |list| ListSerializer.new(list, cantrips: cantrips).as_json }
      end

      def show
        render json: ListSerializer.new(@list).as_json
      end

      def create
        @list = current_user.lists.new(list_params)
        if @list.save
          render json: ListSerializer.new(@list).as_json, status: :created
        else
          render_error(@list.errors)
        end
      end

      def update
        if @list.update(list_params)
          render json: ListSerializer.new(@list).as_json
        else
          render_error(@list.errors)
        end
      end

      def destroy
        @list.destroy
        head :no_content
      end

      # The gang as shareable plain text (CARNEVALEB-74) — see Gang::TextFormat for the format and
      # why illustrations are left out of it. Wrapped in JSON rather than served as text/plain so
      # every endpoint here answers the same way and the generated client needs no special case.
      def export
        render json: { text: Gang::TextFormat.dump(@list) }
      end

      # Builds a *new* gang from that text. Never edits an existing list, so a bad paste costs
      # nothing. `warnings` names what could not be resolved — an unknown model, a spell this build
      # does not have — which is reported rather than fatal, so one typo cannot lose a whole gang.
      def import
        result = Gang::TextImport.call(params.require(:text), owner: current_user)
        render json: { list: ListSerializer.new(result.list).as_json, warnings: result.warnings }, status: :created
      end

      private

      def set_list
        @list = current_user.lists.find(params[:id])
      end

      def list_params
        params.require(:list).permit(:name, :faction, :points)
      end
    end
  end
end
