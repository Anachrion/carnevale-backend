# SPDX-License-Identifier: AGPL-3.0-or-later

require "rails_helper"

RSpec.describe Backoffice::KeywordsHelper, type: :helper do
  let!(:leader) { create(:profile, name: "Capodecina", keywords: [ "Leader", "Trade", "Discipline (Blood Rites, Wild Magic)" ]) }
  let!(:dog) { create(:profile, name: "Hound", keywords: [ "Henchman", "Dog" ]) }

  def data_for(profile)
    helper.keyword_check_data(profile, Catalog::Profile.all.to_a)
  end

  it "offers the keywords and discipline names of the other profiles" do
    data = data_for(Catalog::Profile.new)

    expect(data[:known_keywords]).to eq(%w[Dog Henchman Leader Trade])
    expect(data[:known_disciplines]).to eq([ "Blood Rites", "Wild Magic" ])
  end

  it "counts a keyword only this profile carries once it is saved, so it does not ask on every save" do
    expect(data_for(dog)[:known_keywords]).to include("Dog")
  end

  it "does not count a keyword typed into the form but not saved yet" do
    dog.keywords = [ "Henchman", "Dgo" ]

    expect(data_for(dog)[:known_keywords]).not_to include("Dgo")
  end
end
