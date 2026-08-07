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

  # The back prints special rule prose, and the keywords inside it are bolded against the
  # Catalog::Ability glossary. That list used to be hand-kept in the template and drifted from the
  # catalog, so a keyword could print plain with nothing failing.
  describe "GET card (the back's rule prose)" do
    before { sign_in admin }

    def render_back(rule)
      Catalog::ProfileSpecialRule.create!(profile: profile, special_rule: rule, position: 1)
      get card_backoffice_profile_path(profile), params: { side: "back" }
      response.body
    end

    it "bolds a glossary ability named in a rule, together with its rating" do
      Catalog::Ability.find_or_create_by!(category: "character", name: "Acrobatic")
      rule = Catalog::SpecialRule.create!(name: "Sure Footed", description: "Gain Acrobatic (2).")

      expect(render_back(rule)).to include('<span style="font-weight:700;">Acrobatic (2)</span>')
    end

    it "bolds an ability added to the glossary, with no template change" do
      Catalog::Ability.find_or_create_by!(category: "character", name: "Tide Walker")
      rule = Catalog::SpecialRule.create!(name: "Lagoon Born", description: "Gain Tide Walker (1).")

      expect(render_back(rule)).to include('<span style="font-weight:700;">Tide Walker (1)</span>')
    end

    it "keeps the line breaks an author typed into a description" do
      rule = Catalog::SpecialRule.create!(name: "Spoils", description: "Choose one:\n• More coin\n• More speed")

      expect(render_back(rule)).to match(/white-space:pre-line[^>]*>Choose one:\n• More coin\n• More speed/)
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

  describe "POST create (a new profile and its card)" do
    before { sign_in admin }

    def new_params(profile: {}, card: {})
      {
        profile: {
          name: "New Bravo", faction: "guild", version: "2.2.0",
          ducats: 12, movement: 4, attack: 2, dexterity: 2, protection: 1, mind: 2,
          action_points: 2, will_points: 2, command_points: 0, life_points: 8, size: 30,
          keywords_text: "", abilities_text: ""
        }.merge(profile),
        card: { identifier: "guild-new-bravo" }.merge(card)
      }
    end

    it "renders the new form" do
      get new_backoffice_profile_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="card-preview-front"')
      expect(response.body).to include("card[identifier]")
    end

    it "creates the profile and a single card reference" do
      expect {
        post backoffice_profiles_path, params: new_params
      }.to change(Catalog::Profile, :count).by(1).and change(Catalog::CardReference, :count).by(1)

      created = Catalog::Profile.find_by(name: "New Bravo")
      expect(created.ducats).to eq(12)
      expect(created.card_references.map(&:identifier)).to eq([ "guild-new-bravo" ])
      expect(created.card_references.first.illustration_number).to eq(1)
      expect(response).to redirect_to(edit_backoffice_profile_path(created))
    end

    it "creates an A/B pair sharing the stats" do
      post backoffice_profiles_path, params: new_params(card: { identifier: "guild-twins", pair: "1" })

      created = Catalog::Profile.find_by(name: "New Bravo")
      expect(created.card_references.map(&:identifier)).to contain_exactly("guild-twins-a", "guild-twins-b")
      expect(created.card_references.map(&:illustration_number)).to contain_exactly(1, 2)
    end

    it "attaches weapons chosen on the new form" do
      weapon = Catalog::Weapon.create!(name: "Rapier", damage: 2)

      post backoffice_profiles_path,
        params: new_params(profile: { weapon_ids: [ "", weapon.id ] })

      expect(Catalog::Profile.find_by(name: "New Bravo").weapons).to eq([ weapon ])
    end

    it "rejects a blank identifier and saves nothing" do
      expect {
        post backoffice_profiles_path, params: new_params(card: { identifier: "" })
      }.not_to change(Catalog::Profile, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Identifier can&#39;t be blank")
    end

    it "rejects a duplicate identifier and saves nothing" do
      create(:card_reference, identifier: "guild-taken")

      expect {
        post backoffice_profiles_path, params: new_params(card: { identifier: "guild-taken" })
      }.not_to change(Catalog::Profile, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejects an invalid profile without creating a card" do
      expect {
        post backoffice_profiles_path, params: new_params(profile: { ducats: -1 })
      }.not_to change(Catalog::Profile, :count)

      expect(Catalog::CardReference.count).to eq(0)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "is admin-only" do
      sign_out admin
      sign_in create(:user)

      expect {
        post backoffice_profiles_path, params: new_params
      }.not_to change(Catalog::Profile, :count)
      expect(response).to have_http_status(:forbidden)
    end

    describe "POST new_card_preview (live card for an unsaved profile)" do
      it "renders the card from the form without creating anything" do
        expect {
          post new_card_preview_backoffice_profiles_path,
            params: { profile: new_params[:profile], side: "front" }
        }.not_to change(Catalog::Profile, :count)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("New Bravo")
      end
    end
  end

  describe "PATCH illustration_image (art upload)" do
    let!(:reference) { create(:card_reference, profile: profile, identifier: "guild-capodecina", illustration_number: 1) }
    let(:upload) { fixture_file_upload("art.png", "image/png") }

    before { sign_in admin }

    it "attaches an uploaded image to a slot that had no illustration" do
      expect(profile.illustrations).to be_empty

      patch illustration_image_backoffice_profile_path(profile), params: { number: 1, image: upload }

      illus = profile.illustrations.find_by(number: 1)
      expect(illus.image).to be_attached
      expect(response).to redirect_to(edit_backoffice_profile_path(profile))
    end

    it "makes the card out of date so the publish page offers it" do
      images_dir = Pathname(Dir.mktmpdir)
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
      File.binwrite(reference.front_path, "FRONT")
      File.binwrite(reference.back_path, "BACK")
      reference.stamp_source!
      expect(reference).not_to be_stale

      patch illustration_image_backoffice_profile_path(profile), params: { number: 1, image: upload }

      expect(reference.reload).to be_stale
    ensure
      FileUtils.remove_entry(images_dir)
    end

    it "replaces the art on an existing illustration, changing the fingerprint" do
      patch illustration_image_backoffice_profile_path(profile), params: { number: 1, image: upload }
      first_key = profile.illustrations.find_by(number: 1).source_key

      patch illustration_image_backoffice_profile_path(profile),
        params: { number: 1, image: fixture_file_upload("art.png", "image/png") }

      # A second attach makes a fresh blob; the reference draws the new one.
      expect(profile.illustrations.find_by(number: 1).source_key).to be_present
      expect(first_key).to be_present
    end

    it "reports a missing file rather than saving" do
      patch illustration_image_backoffice_profile_path(profile), params: { number: 1 }

      expect(profile.illustrations).to be_empty
      expect(flash[:alert]).to include("Choose an image")
    end

    # B-38. The specs above post through Rails' test helper, which encodes an UploadedFile as
    # multipart whatever the real form does — so they passed while every browser upload 500'd.
    # These two cover the part they structurally cannot: the enctype the page actually emits, and
    # what the action does with the filename string that arrives when it is missing.
    it "renders the upload form as multipart, so the browser sends the file and not its name" do
      get edit_backoffice_profile_path(profile)

      form = response.body[/<form[^>]*illustration_image[^>]*>/]
      expect(form).to include('enctype="multipart/form-data"')
    end

    it "reports a non-multipart post instead of reading the filename as a signed blob id" do
      patch illustration_image_backoffice_profile_path(profile),
        params: { number: 1, image: "mira-oshea.png" }

      expect(response).to redirect_to(edit_backoffice_profile_path(profile))
      expect(flash[:alert]).to include("Choose an image")
      expect(profile.illustrations).to be_empty
    end

    it "is admin-only" do
      sign_out admin
      sign_in create(:user)

      patch illustration_image_backoffice_profile_path(profile), params: { number: 1, image: upload }

      expect(response).to have_http_status(:forbidden)
      expect(profile.illustrations).to be_empty
    end
  end

  describe "PATCH illustration_position" do
    before { sign_in admin }

    # B-33: repositioning a slot that has no art used to build a path-less illustration and 500 on
    # its own validation; it should redirect back with an alert instead.
    it "redirects with an alert when the slot has no illustration" do
      patch illustration_position_backoffice_profile_path(profile),
        params: { number: 2, offset_x: 0, offset_y: 0, zoom: 100 }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to include("no illustration")
      expect(profile.illustrations).to be_empty
    end
  end

  describe "PATCH update (the profile editor)" do
    let!(:reference) { create(:card_reference, profile: profile, identifier: "guild-capodecina") }

    before do
      sign_in admin
      # valid_params carries these abilities, which are held to the glossary.
      Catalog::Ability.create!(category: "character", name: "Mage")
      Catalog::Ability.create!(category: "character", name: "Expert Sorcerer")
    end

    def valid_params(overrides = {})
      {
        profile: {
          name: "Capodecina", faction: "guild", version: "2.2.0",
          ducats: 20, movement: 4, attack: 3, dexterity: 2, protection: 1, mind: 3,
          action_points: 2, will_points: 3, command_points: 1, life_points: 2, size: 2,
          keywords_text: "Leader\nDiscipline (Blood Rites)",
          abilities_text: "Mage (2)\nExpert Sorcerer (1)"
        }.merge(overrides)
      }
    end

    it "renders the editor with both faces wired to card_preview" do
      get edit_backoffice_profile_path(profile)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="card-preview-front"')
      expect(response.body).to include('id="card-preview-back"')
      expect(response.body).to include(card_preview_backoffice_profile_path(profile))
    end

    it "edits the stats, keywords and abilities" do
      patch backoffice_profile_path(profile), params: valid_params

      expect(response).to redirect_to(edit_backoffice_profile_path(profile))
      profile.reload
      expect(profile.ducats).to eq(20)
      expect(profile.attack).to eq(3)

      # The one-per-line textareas become json arrays of strings, which is what every reader of
      # these columns (the card view, the printed keywords) assumes. Spell pools/granted spells are
      # a separate, explicit concept edited through their own backoffice section (CARNEVALEB-47),
      # not derived from this text — see spec/requests/backoffice/profiles_spec.rb's pools coverage.
      expect(profile.keywords).to eq([ "Leader", "Discipline (Blood Rites)" ])
      expect(profile.abilities).to eq([ "Mage (2)", "Expert Sorcerer (1)" ])
    end

    it "creates a spell pool and a granted spell (CARNEVALEB-47)" do
      rule = Catalog::SpecialRule.create!(name: "Aetheric Gaze", description: "…")
      spell = create(:spell, name: "Waves of Force", discipline: :runes_of_sovereignty)

      # Real unchecked checkboxes submit no key at all (the form has no hidden false-fallback), so
      # "unlimited"/"mentor_derived"/"consumes_slot" are simply omitted here rather than set to "0".
      patch backoffice_profile_path(profile), params: valid_params(
        pools: [ {
          of: "2", slot_count: "4", grants_cantrip: "1", resets_each_round: "1",
          special_rule_id: rule.id.to_s,
          disciplines: [ "blood_rites", "fateweaving", "wild_magic" ]
        } ],
        granted_spells: [ {
          grant_kind: "named_spell", spell_id: spell.id.to_s, resets_each_round: "1"
        } ]
      )

      expect(response).to redirect_to(edit_backoffice_profile_path(profile))
      profile.reload
      pool = profile.profile_spell_pools.sole
      expect(pool.of).to eq(2)
      expect(pool.slot_count).to eq(4)
      expect(pool.grants_cantrip).to be true
      expect(pool.special_rule).to eq(rule)
      expect(pool.disciplines).to match_array(%w[blood_rites fateweaving wild_magic])

      grant = profile.profile_granted_spells.sole
      expect(grant.spell).to eq(spell)
      expect(grant.consumes_slot?).to be false
    end

    it "clears spell pools and granted spells when the form submits none" do
      profile.replace_spell_pools!([ { of: 1, slot_count: 2, disciplines: [ "blood_rites" ] } ])
      profile.replace_granted_spells!([ { grant_kind: "all_cantrips" } ])

      patch backoffice_profile_path(profile), params: valid_params

      profile.reload
      expect(profile.profile_spell_pools).to be_empty
      expect(profile.profile_granted_spells).to be_empty
    end

    it "leaves the card out of date rather than re-rendering it" do
      images_dir = Pathname(Dir.mktmpdir)
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
      File.binwrite(reference.front_path, "FRONT")
      File.binwrite(reference.back_path, "BACK")
      reference.stamp_source!
      expect(reference).not_to be_stale

      expect(Grover).not_to receive(:new)
      patch backoffice_profile_path(profile), params: valid_params(ducats: 99)

      expect(reference.reload).to be_stale
      expect(File.binread(reference.front_path)).to eq("FRONT")
    ensure
      FileUtils.remove_entry(images_dir)
    end

    it "rejects a negative stat and re-renders the form" do
      patch backoffice_profile_path(profile), params: valid_params(ducats: -1)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Ducats must be greater than or equal to 0")
      expect(profile.reload.ducats).to eq(10)
    end

    it "rejects a blank name" do
      patch backoffice_profile_path(profile), params: valid_params(name: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(profile.reload.name).to eq("Capodecina")
    end

    it "rejects an ability that is not in the character glossary" do
      patch backoffice_profile_path(profile),
        params: valid_params(abilities_text: "Mage (2)\nMade Up Ability")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(profile.reload.abilities).not_to include("Made Up Ability")
    end

    it "is admin-only" do
      sign_in create(:user)
      patch backoffice_profile_path(profile), params: valid_params

      expect(response).to have_http_status(:forbidden)
      expect(profile.reload.ducats).to eq(10)
    end

    describe "weapons and special rules" do
      let!(:stiletto) { Catalog::Weapon.create!(name: "Stiletto", damage: 2) }
      let!(:pistol)   { Catalog::Weapon.create!(name: "Pistol", damage: 3, range: 12) }
      let!(:aura)     { Catalog::SpecialRule.create!(name: "Aura", description: "…") }

      # A second profile carrying the same shared weapon: attaching or detaching it here must
      # leave that one alone.
      let!(:other) { create(:profile, faction: "guild", name: "Bravo") }
      let!(:other_claim) { Catalog::ProfileWeapon.create!(profile: other, weapon: stiletto, position: 1) }

      it "attaches them in the order the card prints them" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", pistol.id, stiletto.id ] })

        expect(profile.reload.weapons.map(&:name)).to eq([ "Pistol", "Stiletto" ])
        expect(profile.profile_weapons.map(&:position)).to eq([ 1, 2 ])
      end

      # B-33: a stale weapon id (deleted in another tab between load and save) makes replace_weapons!
      # raise; the editor should re-render with the error, not 500.
      it "re-renders the form when a submitted weapon id no longer exists" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", 999_999 ] })

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "reorders them" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", pistol.id, stiletto.id ] })
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", stiletto.id, pistol.id ] })

        expect(profile.reload.weapons.map(&:name)).to eq([ "Stiletto", "Pistol" ])
      end

      it "empties the list when every row is removed" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", pistol.id ] })
        expect(profile.reload.weapons).to be_present

        # The form's trailing blank entry is what distinguishes "no weapons" from "said nothing".
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "" ] })

        expect(profile.reload.weapons).to be_empty
      end

      it "leaves the shared record, and other profiles' claims on it, alone" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", stiletto.id ] })
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "" ] })

        expect(stiletto.reload.damage).to eq(2)
        expect(other.reload.weapons).to eq([ stiletto ])
        expect(Catalog::ProfileWeapon.exists?(other_claim.id)).to be(true)
      end

      it "attaches special rules too" do
        patch backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { special_rule_ids: [ "", aura.id ] })

        expect(profile.reload.special_rules.map(&:name)).to eq([ "Aura" ])
      end

      it "keeps the lists when the form says nothing about them (Grover's card fetch)" do
        Catalog::ProfileWeapon.create!(profile: profile, weapon: pistol, position: 1)

        patch backoffice_profile_path(profile), params: valid_params(ducats: 21)

        expect(profile.reload.ducats).to eq(21)
        expect(profile.weapons).to eq([ pistol ])
      end

      it "rolls the weapons back when the profile itself is invalid" do
        Catalog::ProfileWeapon.create!(profile: profile, weapon: pistol, position: 1)

        patch backoffice_profile_path(profile),
          params: valid_params(ducats: -1).deep_merge(profile: { weapon_ids: [ "", stiletto.id ] })

        expect(response).to have_http_status(:unprocessable_entity)
        expect(profile.reload.weapons).to eq([ pistol ])
      end

      it "previews an unsaved weapon list without writing the join rows" do
        post card_preview_backoffice_profile_path(profile),
          params: valid_params.deep_merge(profile: { weapon_ids: [ "", pistol.id ] }).merge(side: "back")

        expect(response.body).to include("Pistol")
        expect(profile.reload.weapons).to be_empty
      end
    end

    describe "POST card_preview (the live card)" do
      it "draws the card from the form's values without saving them" do
        post card_preview_backoffice_profile_path(profile), params: valid_params(name: "Renamed", ducats: 44)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Renamed")
        expect(response.body).to include("44")

        # The whole point: the database is untouched, so the preview can show something the
        # catalog does not (yet) contain.
        profile.reload
        expect(profile.name).to eq("Capodecina")
        expect(profile.ducats).to eq(10)
      end

      it "renders the same single-face template Grover screenshots" do
        # side rides alongside the profile hash, not inside it.
        post card_preview_backoffice_profile_path(profile), params: valid_params.merge(side: "back")

        # @side is set, so the card page renders one face and none of its browsing chrome.
        expect(response.body).to include("<!DOCTYPE html>")
        expect(response.body).not_to include("Render to catalog")
        expect(response.body).not_to include("⇄") # the front-only illustration swap button
      end

      it "previews an invalid profile rather than erroring" do
        post card_preview_backoffice_profile_path(profile), params: valid_params(ducats: -5)

        expect(response).to have_http_status(:ok)
      end

      it "is admin-only" do
        sign_in create(:user)
        post card_preview_backoffice_profile_path(profile), params: valid_params

        expect(response).to have_http_status(:forbidden)
      end
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

    it "ignores the render token on other GET actions (index, edit, export)" do
      # The token exists only for Grover's internal fetch of the `card` action; it must not
      # also unlock the rest of the backoffice's read surface (regression for B-18).
      token = Backoffice::BaseController.render_token

      get backoffice_profiles_path(render_token: token)
      expect(response).to redirect_to(new_user_session_path)

      get edit_backoffice_profile_path(profile, render_token: token)
      expect(response).to redirect_to(new_user_session_path)

      get export_pdf_backoffice_profiles_path(render_token: token)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST render_to_catalog" do
    let(:images_dir) { Pathname(Dir.mktmpdir) }
    let!(:reference) { create(:card_reference, profile: profile, identifier: "guild-capodecina") }

    before do
      sign_in admin
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
      # The catalog faces are converted to WebP before they hit disk. libvips can't convert the
      # stand-in strings these Grover stubs return, so stub the conversion with a deterministic
      # tag — enough to prove each Grover face is run through it and lands in the right file.
      # (png_to_webp's real libvips conversion is unit-tested in the model spec.)
      allow(Catalog::CardReference).to receive(:png_to_webp) { |png| "webp:#{png}" }
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

      expect(File.binread(images_dir.join("guild-capodecina-front.webp"))).to eq("webp:FRONT-1")
      expect(File.binread(images_dir.join("guild-capodecina-back.webp"))).to eq("webp:BACK-1")
      expect(reference.reload.internal_version).to eq(1)
      expect(reference.content_digest).to be_present
      expect(response).to redirect_to(card_backoffice_profile_path(profile))
    end

    # Production sets CARD_RENDER_BASE_URL to the container-internal http://localhost, where
    # Thruster listens; TLS is terminated out at kamal-proxy, so nothing answers on 443 inside the
    # container. Handing that base to a _url helper as `host:` dropped the scheme and rebuilt it
    # from force_ssl, sending Chrome to https://localhost — connection refused, every time.
    it "navigates Chrome to CARD_RENDER_BASE_URL exactly, scheme and all" do
      stub_grover_returning(front: "FRONT-1", back: "BACK-1")
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("CARD_RENDER_BASE_URL").and_return("http://localhost")

      # Over HTTPS, as the backoffice is reached in production: the _url helper took its protocol
      # from *this* request, which is what turned the http:// base into https://.
      post render_to_catalog_backoffice_profile_path(profile), headers: { "HTTPS" => "on" }

      expect(Grover).to have_received(:new)
        .with(a_string_starting_with("http://localhost/backoffice/profiles/#{profile.id}/card"), any_args)
        .at_least(:once)
      expect(Grover).not_to have_received(:new).with(a_string_including("https://localhost"), any_args)
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

      expect(File.binread(images_dir.join("guild-capodecina-front.webp"))).to eq("webp:FRONT-A")
      expect(File.binread(images_dir.join("guild-capodecina-b-front.webp"))).to eq("webp:FRONT-B")

      # Each reference owns both faces: the backs hold identical bytes but are its own files.
      expect(File.binread(images_dir.join("guild-capodecina-back.webp"))).to eq("webp:BACK")
      expect(File.binread(images_dir.join("guild-capodecina-b-back.webp"))).to eq("webp:BACK")
      expect(Dir.children(images_dir)).to contain_exactly(
        "guild-capodecina-front.webp", "guild-capodecina-back.webp",
        "guild-capodecina-b-front.webp", "guild-capodecina-b-back.webp"
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

    describe "driven by the publish page (JSON)" do
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

  describe "GET publish" do
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
      get publish_backoffice_profiles_path

      expect(response.body).to include("Capodecina")
      expect(response.body).not_to include(">Bravo<")
      expect(response.body).to include("1 of 2 cards out of date")
    end

    it "lists the whole catalog with scope=all" do
      get publish_backoffice_profiles_path(scope: "all")

      expect(response.body).to include("Capodecina")
      expect(response.body).to include("Bravo")
    end

    it "says there is nothing to do when every card is up to date" do
      stale_ref.destroy!

      get publish_backoffice_profiles_path

      expect(response.body).to include("Nothing to render.")
    end

    it "is admin-only" do
      sign_in create(:user)
      get publish_backoffice_profiles_path

      expect(response).to have_http_status(:forbidden)
    end

    it "shows the generation date of each printable sheet the public page offers" do
      FileUtils.mkdir_p(FactionCardPdf.output_dir)
      FactionCardPdf.output_dir.join("carnevale-guild-cards-2026-08-03.pdf").write("%PDF-1.4")

      get publish_backoffice_profiles_path

      expect(response.body).to include("/cards/pdf/carnevale-guild-cards-2026-08-03.pdf")
      expect(response.body).to include("2026-08-03")
    end

    it "says the public page has nothing when no sheet has been built" do
      get publish_backoffice_profiles_path

      expect(response.body).to include("No print sheet has been built yet")
    end
  end

  describe "POST print_sheets" do
    let(:images_dir) { Pathname(Dir.mktmpdir) }

    before do
      sign_in admin
      stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
    end

    after { FileUtils.remove_entry(images_dir) }

    # A published card: a real (tiny) WebP on each face, which is all FactionCardPdf reads.
    def publish!(reference)
      image = Vips::Image.black(20, 34, bands: 3)
      image.webpsave(reference.front_path.to_s)
      image.webpsave(reference.back_path.to_s)
    end

    it "hands the rebuild to a job rather than doing it in the request" do
      expect { post print_sheets_backoffice_profiles_path }
        .to have_enqueued_job(FactionCardPdfJob)

      expect(response).to redirect_to(publish_backoffice_profiles_path)
      expect(flash[:notice]).to match(/Rebuilding the printable sheets/)
    end

    it "builds the sheets for the factions whose cards are published when the job runs" do
      publish!(create(:card_reference, profile: profile, identifier: "guild-capodecina"))

      perform_enqueued_jobs { post print_sheets_backoffice_profiles_path }

      expect(FactionCardPdf.latest.map(&:faction)).to eq([ "guild" ])
    end

    it "leaves the other factions' sheets unbuilt rather than failing over them" do
      publish!(create(:card_reference, profile: profile, identifier: "guild-capodecina"))
      create(:card_reference, profile: create(:profile, faction: "vatican", name: "Priest"),
        identifier: "vatican-priest")

      expect { perform_enqueued_jobs { post print_sheets_backoffice_profiles_path } }.not_to raise_error

      expect(FactionCardPdf.latest.map(&:faction)).to eq([ "guild" ])
    end

    it "is admin-only" do
      sign_in create(:user)

      expect { post print_sheets_backoffice_profiles_path }.not_to have_enqueued_job(FactionCardPdfJob)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
