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
    class SpellsController < BaseController
      def index
        scope = Catalog::Spell.all
        scope = scope.where(discipline: params[:discipline]) if params[:discipline].present?
        scope = scope.order(:discipline, :cantrip, :name)
        return unless stale?(scope)

        expires_in 1.hour
        render json: scope.map { |s| SpellSerializer.new(s).as_json }
      end
    end
  end
end
