require "rails_helper"

RSpec.describe "Backoffice::Abilities", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:acrobatic) { create(:ability, category: "character", name: "Acrobatic", description: "Re-roll (X) dice.") }

  it "is admin-only" do
    sign_in create(:user)
    get backoffice_abilities_path

    expect(response).to have_http_status(:forbidden)
  end

  context "when signed in as an admin" do
    before { sign_in admin }

    it "lists the abilities of a category with how many cards use each" do
      create(:profile, abilities: [ "Acrobatic (2)" ])

      get backoffice_abilities_path(category: "character")

      expect(response.body).to include("Acrobatic", "1 profile")
    end

    it "creates an ability, prefilled from the profile editor's link" do
      get new_backoffice_ability_path(category: "weapon", name: "Point Blank (2)")
      expect(response.body).to include('value="Point Blank"')

      post backoffice_abilities_path, params: { ability: { category: "weapon", name: "Point Blank", description: "Close range." } }

      expect(response).to redirect_to(backoffice_abilities_path(category: "weapon"))
      expect(Catalog::Ability.find_by(category: "weapon", name: "Point Blank").description).to eq("Close range.")
    end

    it "refuses a name carrying a rating" do
      post backoffice_abilities_path, params: { ability: { category: "character", name: "Brave (1)", description: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Catalog::Ability.find_by(name: "Brave (1)")).to be_nil
    end

    it "renames the ability on the cards that list it, and warns about them beforehand" do
      capo = create(:profile, name: "Capodecina", abilities: [ "Acrobatic (2)" ])
      create(:profile, name: "Bravo", abilities: [ "Acrobatic" ])

      get edit_backoffice_ability_path(acrobatic)
      expect(response.body).to include("Listed by 2 profiles", "Capodecina", "data-turbo-confirm")

      patch backoffice_ability_path(acrobatic), params: { ability: { name: "Acrobatics", description: "Re-roll (X) dice." } }

      expect(flash[:notice]).to include("Renamed on 2 profiles")
      expect(capo.reload.abilities).to eq([ "Acrobatics (2)" ])
    end

    it "deletes an unused ability but not one a card lists" do
      unused = create(:ability, name: "Unused")
      create(:profile, abilities: [ "Acrobatic" ])

      delete backoffice_ability_path(acrobatic)
      expect(flash[:alert]).to include("cannot be deleted")
      expect(Catalog::Ability.exists?(acrobatic.id)).to be(true)

      delete backoffice_ability_path(unused)
      expect(Catalog::Ability.exists?(unused.id)).to be(false)
    end

    it "keeps a history, and undoing a rename renames the cards back" do
      capo = create(:profile, abilities: [ "Acrobatic (2)" ])
      patch backoffice_ability_path(acrobatic), params: { ability: { name: "Acrobatics", description: "Re-roll (X) dice." } }
      rename = Catalog::History.versions_for(acrobatic).last

      get edit_backoffice_ability_path(acrobatic)
      expect(response.body).to include("Name: Acrobatic → Acrobatics")

      post revert_backoffice_version_path(rename)

      expect(response).to redirect_to(edit_backoffice_ability_path(acrobatic))
      expect(acrobatic.reload.name).to eq("Acrobatic")
      expect(capo.reload.abilities).to eq([ "Acrobatic (2)" ])
    end
  end

  # The profile editor rejects an ability the glossary does not know; it now links to create it.
  describe "the profile editor's link to a missing ability" do
    before { sign_in admin }

    it "offers to create the unknown ability, prefilled" do
      profile = create(:profile, name: "Capodecina")

      patch backoffice_profile_path(profile), params: {
        profile: { name: "Capodecina", faction: "guild", version: "2.2.0", keywords_text: "", abilities_text: "Gliding (2)" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(new_backoffice_ability_path(category: "character", name: "Gliding").gsub("&", "&amp;"))
    end
  end
end
