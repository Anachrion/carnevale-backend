module Api
  module V1
    class SpellsController < BaseController
      def index
        spells = Catalog::Spell.all
        spells = spells.where(discipline: params[:discipline]) if params[:discipline].present?
        render json: spells.order(:discipline, :cantrip, :name).map { |s| spell_json(s) }
      end
    end
  end
end
