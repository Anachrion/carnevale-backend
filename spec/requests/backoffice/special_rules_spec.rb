require "rails_helper"

RSpec.describe "Backoffice::SpecialRules", type: :request do
  let(:admin) { create(:user, :admin) }
  let!(:aura) { Catalog::SpecialRule.create!(name: "Mind Gazing", description: "AURA Command Ability.") }

  it "is admin-only" do
    sign_in create(:user)
    get backoffice_special_rules_path

    expect(response).to have_http_status(:forbidden)
  end

  context "when signed in as an admin" do
    before { sign_in admin }

    describe "GET index" do
      it "lists the rules and how many profiles carry each" do
        profile = create(:profile)
        Catalog::ProfileSpecialRule.create!(profile: profile, special_rule: aura, position: 1)

        get backoffice_special_rules_path

        expect(response.body).to include("Mind Gazing")
        expect(response.body).to include("1 profile")
      end

      it "searches by spell name too" do
        Catalog::SpecialRule.create!(name: "", spell_name: "Creative Creation", description: "…")

        get backoffice_special_rules_path, params: { search: "creative" }

        expect(response.body).to include("Creative Creation")
        expect(response.body).not_to include("Mind Gazing")
      end
    end

    describe "POST create" do
      it "creates a plain rule" do
        post backoffice_special_rules_path, params: {
          special_rule: { name: "Fear", description: "Enemies within 6\" test." }
        }

        expect(Catalog::SpecialRule.find_by(name: "Fear").description).to eq("Enemies within 6\" test.")
        expect(response).to redirect_to(backoffice_special_rules_path)
      end

      it "creates a unique spell, which needs no name of its own" do
        post backoffice_special_rules_path, params: {
          special_rule: { name: "", description: "May use the following spell.",
                          spell_name: "Dagonite Baptism", spell_cost: 2, spell_difficulty: 7 }
        }

        rule = Catalog::SpecialRule.find_by(spell_name: "Dagonite Baptism")
        expect(rule.name).to eq("")
        expect(rule.spell_cost).to eq(2)
      end

      it "rejects a rule that is named by neither a name nor a spell" do
        post backoffice_special_rules_path, params: { special_rule: { name: "", description: "…" } }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "leaves the spell columns null rather than zero when the rule is not a spell" do
        post backoffice_special_rules_path, params: {
          special_rule: { name: "Tough", description: "…", spell_cost: "", spell_difficulty: "", spell_name: "" }
        }

        rule = Catalog::SpecialRule.find_by(name: "Tough")
        expect(rule.spell_cost).to be_nil
        expect(rule.spell_difficulty).to be_nil
        expect(rule.spell_name).to be_nil
      end

      # The profile editor's inline "✚ New special rule".
      it "returns the new rule as JSON for the picker" do
        post backoffice_special_rules_path,
          params: { special_rule: { name: "Nimble", description: "…" } }, as: :json

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to include("name" => "Nimble")
      end
    end

    describe "PATCH update" do
      it "edits the rule and reports the cards it invalidated" do
        profile = create(:profile)
        create(:card_reference, profile: profile, identifier: "guild-bravo")
        Catalog::ProfileSpecialRule.create!(profile: profile, special_rule: aura, position: 1)

        patch backoffice_special_rule_path(aura), params: {
          special_rule: { name: "Mind Gazing", description: "Reworded." }
        }

        expect(aura.reload.description).to eq("Reworded.")
        expect(flash[:notice]).to include("1 card now out of date")
      end
    end
  end
end
