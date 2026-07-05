module Gang
  class List < ApplicationRecord
    include HasFaction

    belongs_to :owner, polymorphic: true
    has_many :list_entries, class_name: "Gang::Entry", dependent: :destroy

    validates :name, presence: true
    validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :faction, presence: true

    after_commit :refresh_selection_validity, on: %i[create update]

    def refresh_selection_validity
      return if destroyed?

      result = ListValidationService.call(self)
      update_columns(selection_valid: result[:success], selection_errors: result[:errors])
    end

    def as_json_summary
      { id: id, name: name, faction: faction, points: points, total_cost: list_entries.sum(&:cost) }
    end

    # Deep-copies this list (and its entries) into a new list owned by `owner`, so the copy stays
    # unaffected by any future edits to this one. Used to freeze a player's gang the moment they
    # select it for a game, so a later battle report always reflects what was actually played.
    def snapshot_for(owner)
      List.transaction do
        List.create!(owner: owner, name: name, faction: faction, points: points).tap do |snapshot|
          list_entries.includes(:entry_spells).each do |entry|
            copy = snapshot.list_entries.create!(
              entry_type: entry.entry_type, entry_id: entry.entry_id,
              position: entry.position, spell_discipline: entry.spell_discipline
            )
            entry.entry_spells.each { |es| copy.entry_spells.create!(spell_id: es.spell_id) }
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: lists
#
#  id               :bigint           not null, primary key
#  faction          :string           not null
#  name             :string
#  owner_type       :string           not null
#  points           :integer          default(100), not null
#  selection_errors :json             not null
#  selection_valid  :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  owner_id         :bigint           not null
#
# Indexes
#
#  index_lists_on_owner  (owner_type,owner_id)
#
