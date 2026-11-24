# SPDX-License-Identifier: AGPL-3.0-or-later

require "rails_helper"

RSpec.describe "Backoffice moderator guide", type: :request do
  it "is admin-only" do
    sign_in create(:user)
    get backoffice_guide_path

    expect(response).to have_http_status(:forbidden)
  end

  it "is a tab of every backoffice page, and links the screens it describes" do
    sign_in create(:user, :admin)
    get backoffice_guide_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css(%(header nav a[href="#{backoffice_guide_path}"]))).to be_present
    [ backoffice_profiles_path, publish_backoffice_profiles_path, backoffice_history_path,
      backoffice_abilities_path, backoffice_spells_path ].each do |path|
      expect(page.at_css(%(.guide a[href="#{path}"]))).to be_present, "no link to #{path}"
    end
  end
end
