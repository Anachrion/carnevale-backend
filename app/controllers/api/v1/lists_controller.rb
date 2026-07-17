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
    class ListsController < BaseController
      before_action :authenticate_user!
      before_action :set_list, only: %i[show update destroy]

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
