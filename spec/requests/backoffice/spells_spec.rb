require "rails_helper"

RSpec.describe "Backoffice::Spells", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:boiling) { create(:spell, name: "Boiling Veins", discipline: :blood_rites, cost: 1, difficulty: 3) }

  it "is admin-only" do
    sign_in create(:user)
    get backoffice_spells_path

    expect(response).to have_http_status(:forbidden)
  end

  context "when signed in as an admin" do
    before { sign_in admin }

    it "lists the spells by discipline" do
      get backoffice_spells_path

      expect(response.body).to include("Blood Rites", "Boiling Veins")
    end

    it "creates and edits a spell" do
      post backoffice_spells_path, params: { spell: { name: "Bloodlust", discipline: "blood_rites", cost: 1, difficulty: 6, description: "Gain +(X) ATTACK.", cantrip: "0" } }
      expect(response).to redirect_to(backoffice_spells_path)

      spell = Catalog::Spell.find_by(name: "Bloodlust")
      patch backoffice_spell_path(spell), params: { spell: { difficulty: 5 } }
      expect(spell.reload.difficulty).to eq(5)
    end

    it "allows only one cantrip per discipline" do
      create(:spell, name: "Cantrip of the Devil", discipline: :blood_rites, cantrip: true)

      post backoffice_spells_path, params: { spell: { name: "Another Cantrip", discipline: "blood_rites", cost: 0, difficulty: 7, cantrip: "1" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("already exists for this discipline")
    end

    it "refuses to delete a spell a gang has chosen or a profile is granted" do
      create(:profile).profile_granted_spells.create!(spell: boiling, grant_kind: "named_spell")

      delete backoffice_spell_path(boiling)

      expect(flash[:alert]).to include("cannot be deleted")
      expect(Catalog::Spell.exists?(boiling.id)).to be(true)
    end

    it "deletes an unused spell" do
      delete backoffice_spell_path(boiling)

      expect(Catalog::Spell.exists?(boiling.id)).to be(false)
    end

    it "keeps a history the spell's page lists, with an undo" do
      patch backoffice_spell_path(boiling), params: { spell: { cost: 2 } }
      change = Catalog::History.versions_for(boiling).last

      get edit_backoffice_spell_path(boiling)
      expect(response.body).to include("Cost: 1 → 2")

      post revert_backoffice_version_path(change)
      expect(boiling.reload.cost).to eq(1)

      get backoffice_history_path
      expect(response.body).to include("Spell", "Boiling Veins")
    end
  end
end
