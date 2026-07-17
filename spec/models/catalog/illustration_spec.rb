require 'rails_helper'

RSpec.describe Catalog::Illustration, type: :model do
  let(:profile) { create(:profile, faction: "guild") }

  def with_upload(filename:, content_type:, size: 100)
    illustration = profile.illustrations.build(number: 1)
    illustration.image.attach(io: StringIO.new("x" * size), filename: filename, content_type: content_type)
    illustration
  end

  # B-22: the upload form's accept= is client-side only, so the model must reject non-images and
  # oversized files before they can be stored and rendered onto a published card.
  it "accepts a PNG within the size limit" do
    expect(with_upload(filename: "art.png", content_type: "image/png")).to be_valid
  end

  it "rejects a non-image content type" do
    illustration = with_upload(filename: "notes.txt", content_type: "text/plain")
    expect(illustration).not_to be_valid
    expect(illustration.errors[:image]).to be_present
  end

  it "rejects an oversized image" do
    illustration = with_upload(filename: "huge.png", content_type: "image/png", size: 11.megabytes)
    expect(illustration).not_to be_valid
    expect(illustration.errors[:image]).to be_present
  end
end

# == Schema Information
#
# Table name: illustrations
#
#  id         :bigint           not null, primary key
#  flipped    :boolean          default(FALSE), not null
#  number     :integer          default(1), not null
#  offset_x   :integer          default(0), not null
#  offset_y   :integer          default(0), not null
#  path       :string           not null
#  zoom       :integer          default(100), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#
# Indexes
#
#  index_illustrations_on_profile_id             (profile_id)
#  index_illustrations_on_profile_id_and_number  (profile_id,number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#
