module Gang
  class Entry < ApplicationRecord
    self.table_name = "list_entries"

    belongs_to :list, class_name: "Gang::List"
    belongs_to :entry, polymorphic: true

    delegate :cost, to: :entry

    validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :position, uniqueness: { scope: :list_id }

    after_commit :refresh_list_selection_validity, on: %i[create update destroy]

    private

    def refresh_list_selection_validity
      list.refresh_selection_validity
    end
  end
end

# == Schema Information
#
# Table name: list_entries
#
#  id         :bigint           not null, primary key
#  entry_type :string           not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :bigint           not null
#  list_id    :bigint           not null
#
# Indexes
#
#  index_list_entries_on_entry_type_and_entry_id  (entry_type,entry_id)
#  index_list_entries_on_list_id                  (list_id)
#  index_list_entries_on_list_id_and_position     (list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#
