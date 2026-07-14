require 'rails_helper'

RSpec.describe "Api::V1::Cards", type: :request do
  # Write image bytes so the manifest can report sizes and the reversion task can digest them.
  # IMAGES_DIR is redirected to a throwaway tmp dir per example so the suite never touches (or
  # deletes!) the real, committed public/cards images.
  let(:images_dir) { Pathname(Dir.mktmpdir) }

  def write_card_images(card_reference, front_bytes: "front", back_bytes: "back")
    File.binwrite(images_dir.join(card_reference.card_front), front_bytes)
    File.binwrite(images_dir.join(card_reference.card_back), back_bytes)
  end

  # Filenames are derived, not stored: the front from the reference's identifier, the back from
  # its profile.
  let!(:guild_card) do
    create(:card_reference,
      identifier: "guild-baroni",
      profile: create(:profile, faction: "guild", name: "Baroni"))
  end

  before do
    stub_const("Catalog::CardReference::IMAGES_DIR", images_dir)
    write_card_images(guild_card, front_bytes: "AAA", back_bytes: "BBBB")
  end

  after { FileUtils.remove_entry(images_dir) }

  describe "GET /api/v1/cards/manifest" do
    it "returns one row per card with version, versioned URLs and byte sizes" do
      get "/api/v1/cards/manifest"

      expect(response).to have_http_status(:ok)
      card = JSON.parse(response.body)["cards"].find { |c| c["identifier"] == "guild-baroni" }
      expect(card).to include(
        "identifier" => "guild-baroni",
        "faction" => "guild",
        "internal_version" => 1,
        "front_url" => "/cards/guild-baroni-front.png?v=1",
        "back_url" => "/cards/guild-baroni-back.png?v=1",
        "front_bytes" => 3,
        "back_bytes" => 4
      )
    end

    it "filters by faction when given" do
      create(:card_reference, identifier: "vatican-altar-boy",
        profile: create(:profile, faction: "vatican"))

      get "/api/v1/cards/manifest", params: { faction: "vatican" }

      identifiers = JSON.parse(response.body)["cards"].map { |c| c["identifier"] }
      expect(identifiers).to eq(["vatican-altar-boy"])
    end

    it "advertises a public, cacheable response and returns 304 when unchanged" do
      get "/api/v1/cards/manifest"
      expect(response.headers["Cache-Control"]).to include("public", "max-age")
      etag = response.headers["ETag"]
      expect(etag).to be_present

      get "/api/v1/cards/manifest", headers: { "If-None-Match" => etag }
      expect(response).to have_http_status(:not_modified)
    end
  end

  describe "cards:reversion task" do
    before { Rails.application.load_tasks unless Rake::Task.task_defined?("cards:reversion") }
    after { Rake::Task["cards:reversion"].reenable }

    it "baselines the digest without bumping, then bumps only when image bytes change" do
      expect { Rake::Task["cards:reversion"].invoke }
        .to change { guild_card.reload.content_digest }.from(nil)
      expect(guild_card.internal_version).to eq(1)

      Rake::Task["cards:reversion"].reenable
      expect { Rake::Task["cards:reversion"].invoke }
        .not_to change { guild_card.reload.internal_version }

      write_card_images(guild_card, front_bytes: "CHANGED", back_bytes: "BBBB")
      Rake::Task["cards:reversion"].reenable
      expect { Rake::Task["cards:reversion"].invoke }
        .to change { guild_card.reload.internal_version }.from(1).to(2)
    end
  end
end
