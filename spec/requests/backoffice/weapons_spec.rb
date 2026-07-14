require "rails_helper"

RSpec.describe "Backoffice::Weapons", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:stiletto) { Catalog::Weapon.create!(name: "Stiletto", damage: 2, penetration: -1) }

  describe "authentication" do
    it "is admin-only" do
      sign_in create(:user)
      get backoffice_weapons_path

      expect(response).to have_http_status(:forbidden)
    end

    it "redirects to sign-in when signed out" do
      get backoffice_weapons_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when signed in as an admin" do
    before { sign_in admin }

    describe "GET index" do
      it "lists weapons with the number of profiles carrying each" do
        profile = create(:profile)
        Catalog::ProfileWeapon.create!(profile: profile, weapon: stiletto, position: 1)

        get backoffice_weapons_path

        expect(response.body).to include("Stiletto")
        expect(response.body).to include("1 profile")
      end

      it "searches by name" do
        Catalog::Weapon.create!(name: "Blunderbuss")

        get backoffice_weapons_path, params: { search: "stil" }

        expect(response.body).to include("Stiletto")
        expect(response.body).not_to include("Blunderbuss")
      end
    end

    describe "POST create" do
      it "creates a weapon" do
        %w[Scatter Slow].each { |a| Catalog::Ability.create!(category: "weapon", name: a) }

        post backoffice_weapons_path, params: {
          weapon: { name: "Blunderbuss", damage: 4, penetration: -2, range: 8, abilities_text: "Scatter\nSlow" }
        }

        weapon = Catalog::Weapon.find_by(name: "Blunderbuss")
        expect(weapon.damage).to eq(4)
        expect(weapon.penetration).to eq(-2)
        expect(weapon.abilities).to eq([ "Scatter", "Slow" ])
        expect(response).to redirect_to(backoffice_weapons_path)
      end

      it "rejects a nameless weapon" do
        post backoffice_weapons_path, params: { weapon: { name: "", damage: 1 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(Catalog::Weapon.count).to eq(1)
      end

      it "rejects an ability that is not in the weapon glossary" do
        Catalog::Ability.create!(category: "weapon", name: "Reach")

        post backoffice_weapons_path, params: {
          weapon: { name: "Halberd", damage: 4, abilities_text: "Reach\nInvented Trait" }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(Catalog::Weapon.find_by(name: "Halberd")).to be_nil
      end

      it "accepts a glossary ability, rating and all" do
        Catalog::Ability.create!(category: "weapon", name: "Blast")

        post backoffice_weapons_path, params: {
          weapon: { name: "Bombard", damage: 5, abilities_text: "Blast (3)" }
        }

        expect(Catalog::Weapon.find_by(name: "Bombard").abilities).to eq([ "Blast (3)" ])
      end

      # This is the path the profile editor's inline "✚ New weapon" takes.
      describe "as JSON" do
        it "returns the new weapon so the picker can attach it" do
          post backoffice_weapons_path, params: { weapon: { name: "Cutlass", damage: 3 } }, as: :json

          expect(response).to have_http_status(:created)
          expect(response.parsed_body).to include("name" => "Cutlass")
          expect(response.parsed_body["id"]).to eq(Catalog::Weapon.find_by(name: "Cutlass").id)
        end

        # The inline creator sends the weapon's abilities as a one-per-line string, so a whole
        # weapon — traits and all — can be authored without leaving the card.
        it "accepts the abilities inline" do
          %w[Reach Two-Handed].each { |a| Catalog::Ability.create!(category: "weapon", name: a) }

          post backoffice_weapons_path,
            params: { weapon: { name: "Halberd", damage: 4, abilities_text: "Reach\nTwo-Handed" } }, as: :json

          expect(response).to have_http_status(:created)
          expect(Catalog::Weapon.find_by(name: "Halberd").abilities).to eq([ "Reach", "Two-Handed" ])
        end

        it "returns the errors when it is invalid" do
          post backoffice_weapons_path, params: { weapon: { name: "" } }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["errors"]).to include("Name can't be blank")
        end
      end
    end

    describe "PATCH update" do
      it "edits the weapon and says how many cards it just invalidated" do
        profile = create(:profile)
        create(:card_reference, profile: profile, identifier: "guild-bravo")
        Catalog::ProfileWeapon.create!(profile: profile, weapon: stiletto, position: 1)

        patch backoffice_weapon_path(stiletto), params: { weapon: { name: "Stiletto", damage: 3 } }

        expect(stiletto.reload.damage).to eq(3)
        expect(flash[:notice]).to include("1 card now out of date")
      end

      # The payoff of the source fingerprint: a shared record changing puts every card that
      # carries it onto the publish page, with nobody having to remember which ones those are.
      it "makes the cards of every profile carrying it stale" do
        images_dir = Pathname(Dir.mktmpdir)
        stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)

        profile = create(:profile)
        reference = create(:card_reference, profile: profile, identifier: "guild-bravo")
        Catalog::ProfileWeapon.create!(profile: profile, weapon: stiletto, position: 1)
        File.binwrite(reference.front_path, "FRONT")
        File.binwrite(reference.back_path, "BACK")
        reference.stamp_source!
        expect(reference).not_to be_stale

        patch backoffice_weapon_path(stiletto), params: { weapon: { name: "Stiletto", damage: 9 } }

        expect(reference.reload).to be_stale
      ensure
        FileUtils.remove_entry(images_dir)
      end
    end

    describe "DELETE destroy" do
      it "deletes a weapon no profile carries" do
        delete backoffice_weapon_path(stiletto)

        expect(Catalog::Weapon.exists?(stiletto.id)).to be(false)
        expect(response).to redirect_to(backoffice_weapons_path)
      end

      it "refuses to delete a weapon a profile still carries" do
        Catalog::ProfileWeapon.create!(profile: create(:profile), weapon: stiletto, position: 1)

        delete backoffice_weapon_path(stiletto)

        expect(Catalog::Weapon.exists?(stiletto.id)).to be(true)
        expect(flash[:alert]).to include("cannot be deleted")
      end

      it "is admin-only" do
        sign_out admin
        sign_in create(:user)

        delete backoffice_weapon_path(stiletto)

        expect(response).to have_http_status(:forbidden)
        expect(Catalog::Weapon.exists?(stiletto.id)).to be(true)
      end
    end
  end
end
