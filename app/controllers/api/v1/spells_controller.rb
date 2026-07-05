module Api
  module V1
    class SpellsController < BaseController
      def index
        scope = Catalog::Spell.all
        scope = scope.where(discipline: params[:discipline]) if params[:discipline].present?
        scope = scope.order(:discipline, :cantrip, :name)
        return unless stale?(scope, public: true)

        expires_in 1.hour, public: true
        render json: scope.map { |s| spell_json(s) }
      end
    end
  end
end
