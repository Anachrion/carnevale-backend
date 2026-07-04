module Api
  module V1
    class ProfilesController < BaseController
      def index
        profiles = Catalog::Profile.includes(:weapons, :special_rules, :card_references)
        profiles = profiles.where(faction: params[:faction]) if params[:faction].present?
        render json: profiles.map { |p| profile_json(p) }
      end

      def show
        profile = Catalog::Profile.includes(:weapons, :special_rules, :card_references).find(params[:id])
        render json: profile_json(profile)
      end

      private

      def profile_json(profile)
        {
          id: profile.id,
          name: profile.name,
          faction: profile.faction,
          ducats: profile.ducats,
          movement: profile.movement,
          attack: profile.attack,
          dexterity: profile.dexterity,
          life_points: profile.life_points,
          mind: profile.mind,
          will_points: profile.will_points,
          protection: profile.protection,
          action_points: profile.action_points,
          command_points: profile.command_points,
          size: profile.size,
          abilities: profile.abilities,
          keywords: profile.keywords,
          version: profile.version,
          weapons: profile.weapons.map { |w|
            { id: w.id, name: w.name, damage: w.damage, range: w.range,
              penetration: w.penetration, evasion: w.evasion, abilities: w.abilities }
          },
          special_rules: profile.special_rules.map { |sr|
            { id: sr.id, name: sr.name, description: sr.description,
              spell_name: sr.spell_name, spell_cost: sr.spell_cost,
              spell_difficulty: sr.spell_difficulty, spell_description: sr.spell_description }
          },
          card_references: profile.card_references.map { |cr|
            { id: cr.id, identifier: cr.identifier, name: cr.name,
              card_front: cr.card_front, card_back: cr.card_back }
          }
        }
      end
    end
  end
end
