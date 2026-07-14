require "rails_helper"

RSpec.describe "Backoffice::Profiles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:profile) { create(:profile, faction: "guild", name: "Capodecina") }

  describe "authentication and admin gate" do
    it "redirects the index to sign-in when signed out" do
      get backoffice_profiles_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects the card page to sign-in when signed out and no render token" do
      get card_backoffice_profile_path(profile)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "forbids a signed-in non-admin (regular app user)" do
      sign_in create(:user)
      get backoffice_profiles_path
      expect(response).to have_http_status(:forbidden)
    end

    it "forbids a non-admin on the card page even though it renders catalog data" do
      sign_in create(:user)
      get card_backoffice_profile_path(profile), params: { side: "front" }
      expect(response).to have_http_status(:forbidden)
    end

    it "serves the card page to a signed-in admin" do
      sign_in admin
      get card_backoffice_profile_path(profile), params: { side: "front" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(profile.name)
    end
  end

  describe "GET index (the sticky filter)" do
    let!(:capodecina) { profile }
    let!(:bombardier) { create(:profile, faction: "guild", name: "Bombardier") }

    before { sign_in admin }

    it "filters by name and remembers the filter for a later bare visit" do
      get backoffice_profiles_path, params: { search: "capo" }
      expect(response.body).to include("Capodecina")
      expect(response.body).not_to include("Bombardier")

      # A bare visit (e.g. coming back from a card tab) replays the stored filter, and the toolbar
      # and sort links have to show it — otherwise the list looks filtered for no visible reason.
      get backoffice_profiles_path
      expect(response.body).not_to include("Bombardier")
      expect(response.body).to include('value="capo"')
      expect(response.body).to include("search=capo")
    end

    it "shows the internal_version the app sees for each profile's cards" do
      create(:card_reference, profile: capodecina, identifier: "guild-capo-a", internal_version: 2)
      create(:card_reference, profile: capodecina, identifier: "guild-capo-b", internal_version: 3)

      get backoffice_profiles_path, params: { search: "capo" }

      # An A/B pair can sit at different versions, so both are listed.
      expect(response.body).to include("v2, v3")
    end

    it "shows a dash for a profile with no card" do
      get backoffice_profiles_path, params: { search: "bombardier" }

      expect(response.body).to include("—")
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
    let!(:reference) { create(:card_reference, profile: profile, identifier: "guild-capodecina") }

    before do
      sign_in admin
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

    it "gives each card reference of an A/B pair both of its faces, with its own illustration" do
      ref_b = create(:card_reference, profile: profile, identifier: "guild-capodecina-b",
        illustration_number: 2)
      create(:illustration, profile: profile, number: 1, path: "p01_a.png")
      create(:illustration, profile: profile, number: 2, path: "p01_b.png")

      # One Grover render per distinct face, in order: reference A's front, reference B's front,
      # then the back — which has no illustration and so is rendered once for the profile.
      grover = instance_double(Grover)
      allow(Grover).to receive(:new).and_return(grover)
      allow(grover).to receive(:to_png).and_return("FRONT-A", "FRONT-B", "BACK")

      post render_to_catalog_backoffice_profile_path(profile)

      expect(File.binread(images_dir.join("guild-capodecina-front.png"))).to eq("FRONT-A")
      expect(File.binread(images_dir.join("guild-capodecina-b-front.png"))).to eq("FRONT-B")

      # Each reference owns both faces: the backs hold identical bytes but are its own files.
      expect(File.binread(images_dir.join("guild-capodecina-back.png"))).to eq("BACK")
      expect(File.binread(images_dir.join("guild-capodecina-b-back.png"))).to eq("BACK")
      expect(Dir.children(images_dir)).to contain_exactly(
        "guild-capodecina-front.png", "guild-capodecina-back.png",
        "guild-capodecina-b-front.png", "guild-capodecina-b-back.png"
      )

      # Each front is fetched with the illustration its reference points at.
      expect(Grover).to have_received(:new).with(a_string_including("illustration=1"), any_args)
      expect(Grover).to have_received(:new).with(a_string_including("illustration=2"), any_args)
      expect(ref_b.reload.content_digest).to be_present
    end

    it "records the sources it rendered from, so the card stops reporting as stale" do
      stub_grover_returning(front: "FRONT-1", back: "BACK-1")

      expect(reference).to be_stale
      post render_to_catalog_backoffice_profile_path(profile)

      expect(reference.reload.source_digest).to be_present
      expect(reference).not_to be_stale

      # ...until the profile it is drawn from moves on.
      profile.update!(ducats: 99)
      expect(reference.reload).to be_stale
    end

    describe "driven by the render queue (JSON)" do
      it "reports what it rendered" do
        stub_grover_returning(front: "FRONT-1", back: "BACK-1")
        post render_to_catalog_backoffice_profile_path(profile), as: :json
        expect(response.parsed_body).to include("name" => "Capodecina", "cards" => 1, "bumped" => 0)

        stub_grover_returning(front: "FRONT-2", back: "BACK-2")
        post render_to_catalog_backoffice_profile_path(profile), as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include("bumped" => 1, "versions" => [ 2 ])
      end

      it "reports a failed render instead of taking the queue down" do
        allow(Grover).to receive(:new).and_raise(StandardError, "Chrome died")

        post render_to_catalog_backoffice_profile_path(profile), as: :json

        expect(response).to have_http_status(:internal_server_error)
        expect(response.parsed_body).to include("name" => "Capodecina", "error" => "Chrome died")
      end
    end
  end

  describe "GET render_queue" do
    let(:images_dir) { Pathname(Dir.mktmpdir) }
    let!(:stale_ref) { create(:card_reference, profile: profile, identifier: "guild-capodecina") }
    let(:fresh_profile) { create(:profile, faction: "guild", name: "Bravo") }
    let!(:fresh_ref) { create(:card_reference, profile: fresh_profile, identifier: "guild-bravo") }

    before do
      sign_in admin
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)

      # Bravo's images are on disk and stamped; Capodecina's were never rendered.
      File.binwrite(fresh_ref.front_path, "FRONT")
      File.binwrite(fresh_ref.back_path, "BACK")
      fresh_ref.stamp_source!
    end

    after { FileUtils.remove_entry(images_dir) }

    it "lists only the profiles whose cards are out of date" do
      get render_queue_backoffice_profiles_path

      expect(response.body).to include("Capodecina")
      expect(response.body).not_to include(">Bravo<")
      expect(response.body).to include("1 of 2 cards out of date")
    end

    it "lists the whole catalog with scope=all" do
      get render_queue_backoffice_profiles_path(scope: "all")

      expect(response.body).to include("Capodecina")
      expect(response.body).to include("Bravo")
    end

    it "says there is nothing to do when every card is up to date" do
      stale_ref.destroy!

      get render_queue_backoffice_profiles_path

      expect(response.body).to include("Nothing to render.")
    end

    it "is admin-only" do
      sign_in create(:user)
      get render_queue_backoffice_profiles_path

      expect(response).to have_http_status(:forbidden)
    end
  end
end
