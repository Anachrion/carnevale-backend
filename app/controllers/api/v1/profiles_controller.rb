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
    class ProfilesController < BaseController
      def index
        scope = Catalog::Profile.all
        scope = scope.where(faction: params[:faction]) if params[:faction].present?
        return unless stale?(etag: catalog_etag(scope))

        expires_in 1.hour
        profiles = scope.includes(:weapons, :special_rules, :card_references, profile_spell_pools: :profile_spell_pool_disciplines)
        render json: profiles.map { |p| profile_json(p) }
      end

      def show
        profile = Catalog::Profile.includes(:weapons, :special_rules, :card_references, profile_spell_pools: :profile_spell_pool_disciplines).find(params[:id])
        return unless stale?(etag: catalog_etag(profile))

        expires_in 1.hour
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
          # A Leader that demotes to a plain Hero alongside another Leader (The Duke, Prince of
          # Thieves, Sopracomito, La Signora) — lets the gang builder keep offering its "add" button
          # once a Leader is present. Enforcement is ListValidationService#check_leader_count.
          flexible_leader: profile.flexible_leader,
          # Whether this model may be hired or summoned directly. False for a model that can only
          # arrive as another model's companion (the Emissary's Tentacles) — the client drops it from
          # the hire search and the summon picker, though it stays browsable in the Cards catalog.
          recruitable: profile.recruitable,
          # The specific partner a *conditional* flex Leader demotes alongside (La Signora -> Il
          # Capitano's profile id), or null when it demotes alongside any Leader. Lets the builder
          # restrict which Leader can still be recruited once she's in the list.
          flexible_leader_with: profile.flexible_leader_with_id,
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
