require "rails_helper"
require "tmpdir"

# The standalone public pages. They are linked from outside the app (the Play listing points at
# /privacy and /account-deletion; /cards is where players are sent for printable cards), so each one
# has to resolve for a visitor with no account at all.
RSpec.describe "Public pages", type: :request do
  describe "GET /privacy" do
    it "serves without a login" do
      get "/privacy"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /account-deletion" do
    it "serves without a login" do
      get "/account-deletion"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /cards" do
    let(:cards_dir) { Pathname(Dir.mktmpdir) }
    before { stub_const("Catalog::CardReference::IMAGES_DIR", cards_dir) }
    after { FileUtils.remove_entry(cards_dir) }

    def write_sheet(faction, date)
      FileUtils.mkdir_p(FactionCardPdf.output_dir)
      FactionCardPdf.output_dir.join("carnevale-#{faction}-cards-#{date}.pdf").write("%PDF-1.4")
    end

    it "serves without a login" do
      get "/cards"

      expect(response).to have_http_status(:ok)
    end

    it "links the newest sheet per faction" do
      write_sheet("guild", "2026-07-01")
      write_sheet("guild", "2026-08-03")
      write_sheet("vatican", "2026-08-03")

      get "/cards"

      expect(response.body).to include("/cards/pdf/carnevale-guild-cards-2026-08-03.pdf")
      expect(response.body).to include("/cards/pdf/carnevale-vatican-cards-2026-08-03.pdf")
      expect(response.body).not_to include("carnevale-guild-cards-2026-07-01.pdf")
    end

    it "says so rather than showing an empty list when nothing has been generated" do
      get "/cards"

      expect(response.body).to include("have not been generated yet")
    end
  end
end
