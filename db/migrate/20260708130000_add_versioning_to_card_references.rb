class AddVersioningToCardReferences < ActiveRecord::Migration[8.1]
  def change
    # Monotonic version of a card's downloadable images (front + back). Bumped by the
    # cards:reversion task whenever the image bytes change, so the app can re-download only
    # the cards that actually changed. Stats live on profiles and are refreshed separately.
    add_column :card_references, :internal_version, :integer, null: false, default: 1
    # SHA256 of the front+back image bytes at the time internal_version was last set; used to
    # detect image changes without a manual bump.
    add_column :card_references, :content_digest, :string
  end
end
