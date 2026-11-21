require "rails_helper"

RSpec.describe "Backoffice catalog history", type: :request do
  let(:admin) { create(:user, :admin, username: "moderator1") }
  # The same stats profile_params submits, so an unchanged form is a genuine no-op save.
  let(:profile) do
    create(:profile, faction: "guild", name: "Capodecina", ducats: 20, movement: 4, attack: 3, dexterity: 2,
           protection: 1, mind: 3, action_points: 2, will_points: 3, command_points: 1, life_points: 2, size: 2)
  end
  let!(:reference) { create(:card_reference, profile: profile, identifier: "guild-capodecina") }
  let!(:stiletto) { Catalog::Weapon.create!(name: "Stiletto", damage: 1) }
  let!(:pistol)   { Catalog::Weapon.create!(name: "Pistol", damage: 2, range: 12) }

  before { profile.replace_weapons!([ stiletto.id ]) }

  def profile_params(overrides = {})
    {
      profile: {
        name: "Capodecina", faction: "guild", version: "2.2.0",
        ducats: 20, movement: 4, attack: 3, dexterity: 2, protection: 1, mind: 3,
        action_points: 2, will_points: 3, command_points: 1, life_points: 2, size: 2,
        keywords_text: "", abilities_text: "", weapon_ids: [ stiletto.id.to_s ]
      }.merge(overrides)
    }
  end

  describe "admin gate" do
    it "redirects signed-out visitors to sign-in" do
      get backoffice_history_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "forbids a non-admin from the history and from reverting" do
      sign_in create(:user)
      version = PaperTrail::Version.create!(item_type: "Catalog::Profile", item_id: profile.id, event: "update",
                                            card_snapshot: Catalog::CardSnapshot.capture(profile))

      get history_backoffice_profile_path(profile)
      expect(response).to have_http_status(:forbidden)
      post revert_backoffice_version_path(version)
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "signed in as an admin" do
    before { sign_in admin }

    it "records a card edit, its weapons included, under the admin's name" do
      patch backoffice_profile_path(profile), params: profile_params(ducats: 25, weapon_ids: [ pistol.id.to_s ])

      version = Catalog::History.versions_for(profile).last
      expect(version.event).to eq("update")
      expect(version.whodunnit).to eq(admin.id.to_s)
      expect(Catalog::History.changes(version)).to include("Ducats: 20 → 25", "Weapon removed: Stiletto", "Weapon added: Pistol")

      get history_backoffice_profile_path(profile)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("moderator1", "Weapon removed: Stiletto")

      get backoffice_history_path
      expect(response.body).to include("Capodecina", "Ducats: 20 → 25")
    end

    it "labels each card's latest version Current instead of offering a restore that does nothing" do
      patch backoffice_profile_path(profile), params: profile_params(ducats: 25)
      baseline, current = Catalog::History.versions_for(profile).to_a

      get backoffice_history_path

      expect(response.body).to include("Current", "Card before its first recorded change")
      expect(response.body).to include(revert_backoffice_version_path(baseline))
      expect(response.body).not_to include(revert_backoffice_version_path(current))
    end

    it "records nothing when a save changes nothing" do
      patch backoffice_profile_path(profile), params: profile_params

      expect(Catalog::History.versions_for(profile)).to be_empty
    end

    it "restores a card version: stats and weapons come back, and the revert is itself recorded" do
      patch backoffice_profile_path(profile), params: profile_params(ducats: 25, weapon_ids: [ pistol.id.to_s ])
      baseline = Catalog::History.versions_for(profile).first

      post revert_backoffice_version_path(baseline)

      expect(response).to redirect_to(history_backoffice_profile_path(profile))
      profile.reload
      expect(profile.ducats).to eq(20)
      expect(profile.weapons).to eq([ stiletto ])
      revert = Catalog::History.versions_for(profile).last
      expect(revert).to have_attributes(event: "revert", reverted_from_id: baseline.id, whodunnit: admin.id.to_s)
    end

    it "says so when the card is already in that state" do
      patch backoffice_profile_path(profile), params: profile_params(ducats: 25)
      current = Catalog::History.versions_for(profile).last

      post revert_backoffice_version_path(current)

      expect(flash[:notice]).to include("already in that state")
    end

    it "undoes a weapon change and lists it on the weapon's page" do
      patch backoffice_weapon_path(stiletto), params: { weapon: { name: "Stiletto", damage: 3, evasion: 0, penetration: 0, range: 0, abilities_text: "" } }
      change = Catalog::History.versions_for(stiletto).last
      expect(change.whodunnit).to eq(admin.id.to_s)

      get edit_backoffice_weapon_path(stiletto)
      expect(response.body).to include("Damage: 1 → 3")

      post revert_backoffice_version_path(change)

      expect(response).to redirect_to(edit_backoffice_weapon_path(stiletto))
      expect(stiletto.reload.damage).to eq(1)
      expect(Catalog::History.versions_for(stiletto).last.reverted_from_id).to eq(change.id)
    end
  end
end
