# SPDX-License-Identifier: AGPL-3.0-or-later

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
