module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

      # The whole API is consumed only by our own frontends, so require a shared client key on
      # every request. It is baked into the frontend builds — a public client can never keep a
      # secret truly private, so this only raises the bar against random bots / scrapers / curl;
      # rate limiting (Rack::Attack) and CORS are the complementary layers. When API_KEY is unset
      # (development, test, and any environment that hasn't opted in) the check is skipped so
      # local workflows keep working; set API_KEY to enforce it.
      before_action :authenticate_client!

      private

      def authenticate_client!
        expected = ENV["API_KEY"]
        return if expected.blank?

        provided = request.headers["X-Api-Key"].to_s
        return if ActiveSupport::SecurityUtils.secure_compare(provided, expected)

        render_error("Unauthorized client", status: :unauthorized)
      end

      def render_error(message, status: :unprocessable_entity)
        render json: { errors: { base: [ message ] } }, status: status
      end

      def list_json(list, with_entries: false)
        json = {
          id: list.id,
          name: list.name,
          faction: list.faction,
          points: list.points,
          total_cost: list.list_entries.sum(&:cost),
          selection_valid: list.selection_valid,
          selection_errors: list.selection_errors
        }
        if with_entries
          entries = list.list_entries.includes(:entry, :entry_state, entry_spells: :spell).order(:position)
          json[:entries] = entries.map { |list_entry| entry_json(list_entry) }
        end
        json
      end

      def entry_json(list_entry)
        profile = list_entry.profile
        {
          id: list_entry.id,
          position: list_entry.position,
          entry_type: list_entry.entry_type,
          entry_id: list_entry.entry_id,
          name: list_entry.entry.name,
          cost: list_entry.cost,
          # Only present once the game has started (Encounter::Game#start!); nil beforehand
          # and for equipment entries, which have no HP/WP/CP to track.
          state: list_entry.entry_state&.as_json_for_display,
          # Spell selection (rulebook p24). `mage` gates the Spells button in the gang builder;
          # non-Mage entries carry mage: false and no disciplines/spells.
          mage: profile&.mage? || false,
          spell_slots: profile&.spell_slots || 0,
          disciplines: profile&.disciplines || [],
          spell_discipline: list_entry.spell_discipline,
          cantrip: (Catalog::Spell.cantrip_for(list_entry.spell_discipline) if list_entry.spell_discipline.present?)&.then { |c| spell_json(c) },
          spells: list_entry.entry_spells.map { |es| spell_json(es.spell) }
        }
      end

      def spell_json(spell)
        {
          id: spell.id,
          name: spell.name,
          discipline: spell.discipline,
          cost: spell.cost,
          difficulty: spell.difficulty,
          cantrip: spell.cantrip,
          description: spell.description
        }
      end
    end
  end
end
