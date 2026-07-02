class List < ApplicationRecord
  include HasFaction

  belongs_to :user
  has_many :list_entries, dependent: :destroy

  validates :name, presence: true
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :faction, presence: true

  after_commit :refresh_selection_validity, on: %i[create update]

  def refresh_selection_validity
    return if destroyed?

    result = ListValidationService.call(self)
    update_columns(selection_valid: result[:success], selection_errors: result[:errors])
  end
end

# == Schema Information
#
# Table name: lists
#
#  id               :bigint           not null, primary key
#  faction          :string           not null
#  name             :string
#  points           :integer          default(100), not null
#  selection_errors :json             not null
#  selection_valid  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
