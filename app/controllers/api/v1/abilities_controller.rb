# SPDX-License-Identifier: AGPL-3.0-or-later

module Api
  module V1
    class AbilitiesController < BaseController
      def index
        scope = Catalog::Ability.all
        scope = scope.where(category: params[:category]) if params[:category].present?
        scope = scope.order(:category, :name)
        return unless stale?(scope)

        expires_in 1.hour
        render json: scope.map { |a| { name: a.name, category: a.category, description: a.description } }
      end
    end
  end
end
