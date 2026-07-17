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
    class ProfilesController < BaseController
      def index
        scope = Catalog::Profile.all
        scope = scope.where(faction: params[:faction]) if params[:faction].present?
        return unless stale?(etag: catalog_etag(scope), public: true)

        expires_in 1.hour, public: true
        profiles = scope.includes(:weapons, :special_rules, :card_references, profile_spell_pools: :profile_spell_pool_disciplines)
        render json: profiles.map { |p| profile_json(p) }
      end

      def show
        profile = Catalog::Profile.includes(:weapons, :special_rules, :card_references, profile_spell_pools: :profile_spell_pool_disciplines).find(params[:id])
        return unless stale?(etag: catalog_etag(profile), public: true)

        expires_in 1.hour, public: true
        render json: profile_json(profile)
      end

      private

      # The payload embeds weapons, special rules and card references — records shared across
      # profiles and edited on their own screens, which touch neither the profile row nor the join
      # table. Keying the ETag on the profile scope alone therefore served stale stats after a
      # weapon/rule errata (a 304 for up to the full cache window). Fold each collection's newest
      # updated_at and row count into the ETag so any edit to embedded data busts it too. Global
      # maxima are a deliberate over-approximation: never stale, at worst a few needless 200s.
      def catalog_etag(profile_or_scope)
        # cache_key_with_version, not maximum(:updated_at): it renders the timestamp at microsecond
        # precision (count + max updated_at), so an edit that lands in the same wall-clock second as
        # the previous one still changes the key — plain to_s serialization is only second-precise.
        [
          profile_or_scope.cache_key_with_version,
          Catalog::Weapon.all.cache_key_with_version,
          Catalog::SpecialRule.all.cache_key_with_version,
          Catalog::CardReference.all.cache_key_with_version,
          Catalog::ProfileSpellPool.all.cache_key_with_version,
          Catalog::ProfileGrantedSpell.all.cache_key_with_version
        ]
      end

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
          # Spell-selection metadata derived from abilities/keywords (rulebook p24).
          mage: profile.mage?,
          spell_slots: profile.spell_slots,
          disciplines: profile.disciplines,
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
