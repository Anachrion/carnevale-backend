require "rails_helper"

RSpec.describe "Backoffice::Profiles", type: :request do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, faction: "guild", name: "Capodecina") }

  describe "authentication" do
    it "redirects the index to sign-in when signed out" do
      get backoffice_profiles_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects the card page to sign-in when signed out and no render token" do
      get card_backoffice_profile_path(profile)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "serves the card page to a signed-in user" do
      sign_in user
      get card_backoffice_profile_path(profile), params: { side: "front" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(profile.name)
    end
  end

  describe "render token bypass (used by Grover)" do
    it "serves the card page with a valid render token and no session" do
      get card_backoffice_profile_path(profile), params: {
        side: "front", render_token: Backoffice::BaseController.render_token
      }
      expect(response).to have_http_status(:ok)
    end

    it "rejects an invalid render token" do
      get card_backoffice_profile_path(profile), params: { side: "front", render_token: "nope" }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ignores the render token on non-GET actions" do
      # render_to_catalog is POST, so a token must not let it through unauthenticated.
      post render_to_catalog_backoffice_profile_path(profile), params: {
        render_token: Backoffice::BaseController.render_token
      }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST render_to_catalog" do
    let(:images_dir) { Pathname(Dir.mktmpdir) }
    let!(:reference) do
      create(:card_reference, profile: profile,
        card_front: "guild-capodecina-front.png", card_back: "guild-capodecina-back.png")
    end

    before do
      sign_in user
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
    end

    after { FileUtils.remove_entry(images_dir) }

    def stub_grover_returning(front:, back:)
      grover = instance_double(Grover)
      allow(Grover).to receive(:new).and_return(grover)
      allow(grover).to receive(:to_png).and_return(front, back)
    end

    it "writes the rendered faces into the catalog and baselines the version" do
      stub_grover_returning(front: "FRONT-1", back: "BACK-1")

      post render_to_catalog_backoffice_profile_path(profile)

      expect(File.binread(images_dir.join("guild-capodecina-front.png"))).to eq("FRONT-1")
      expect(File.binread(images_dir.join("guild-capodecina-back.png"))).to eq("BACK-1")
      expect(reference.reload.internal_version).to eq(1)
      expect(reference.content_digest).to be_present
      expect(response).to redirect_to(card_backoffice_profile_path(profile))
    end

    it "bumps internal_version when a re-render changes the bytes" do
      stub_grover_returning(front: "FRONT-1", back: "BACK-1")
      post render_to_catalog_backoffice_profile_path(profile)
      expect(reference.reload.internal_version).to eq(1)

      stub_grover_returning(front: "FRONT-2", back: "BACK-2")
      post render_to_catalog_backoffice_profile_path(profile)
      expect(reference.reload.internal_version).to eq(2)
    end

    it "does not bump the version when a re-render is byte-identical" do
      stub_grover_returning(front: "SAME-F", back: "SAME-B")
      post render_to_catalog_backoffice_profile_path(profile)

      stub_grover_returning(front: "SAME-F", back: "SAME-B")
      post render_to_catalog_backoffice_profile_path(profile)

      expect(reference.reload.internal_version).to eq(1)
    end
  end
end
