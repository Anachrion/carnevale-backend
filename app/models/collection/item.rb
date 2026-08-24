# Carnevale Companion — Backend
# Copyright (C) 2026 Anachrion and contributors
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

module Collection
  # One catalog profile in one player's collection: how many miniatures they own, how many of those
  # are assembled, and how many of those are painted (CARNEVALEB-76).
  #
  # The three counts *nest* — painted <= built <= owned — because that is what the objects on the
  # shelf do: nobody paints a miniature they have not assembled, or assembles one they do not own.
  # Storing them as three independent totals and reconciling in the client would let the two drift
  # apart; here the invariant is normalised on the way in and enforced by a check constraint.
  class Item < ApplicationRecord
    self.table_name = "collection_items"

    belongs_to :user
    belongs_to :profile, class_name: "Catalog::Profile"

    COUNTS = %i[owned built painted].freeze

    validates(*COUNTS, numericality: { only_integer: true, greater_than_or_equal_to: 0 })
    validates :profile_id, uniqueness: { scope: :user_id }

    before_validation :normalize_counts

    # Sets one profile's counts for one player, whatever state the row was in — the single write
    # path behind both the per-profile and the bulk endpoint.
    #
    # A row whose three counts all reach zero is destroyed rather than kept: "owns none of these"
    # and "has never said anything about these" are the same fact, and only one of them should
    # cost a row. The returned item is the (possibly destroyed, still readable) record, so the
    # caller can render the resulting counts either way.
    def self.set!(user:, profile_id:, counts:)
      item = user.collection_items.find_or_initialize_by(profile_id: profile_id)
      item.assign_attributes(counts.slice(*COUNTS))
      item.normalize_counts

      if item.empty?
        item.destroy if item.persisted?
      else
        item.save!
      end
      item
    end

    def empty?
      COUNTS.all? { |count| public_send(count).to_i.zero? }
    end

    # Pulls the three counts back into `painted <= built <= owned`.
    #
    # Which side gives way depends on which count the caller just moved, so that a single stepper
    # tap does the obvious thing in both directions: marking a miniature painted when none were
    # assembled pulls `built` (and `owned`) up with it, while dropping `owned` to 1 pushes `built`
    # and `painted` back down to 1. Raising a narrow count therefore never silently fails, and
    # lowering a wide one never leaves a wider count stranded above it.
    def normalize_counts
      COUNTS.each { |count| public_send("#{count}=", [ public_send(count).to_i, 0 ].max) }

      # Capture the directions before mutating: assigning below would make every count look "moved".
      painted_up = raised?(:painted)
      built_up = raised?(:built)

      if painted > built
        painted_up ? self.built = painted : self.painted = built
      end
      if built > owned
        built_up ? self.owned = built : self.built = owned
      end
      # `built` may itself have just been pushed down to `owned`, taking it back under `painted`.
      self.painted = [ painted, built ].min
    end

    private

    # Whether this write raises [count]. Everything on a new record counts as a rise, so a first
    # write of `painted: 1` provisions the `built`/`owned` it implies rather than clamping to zero.
    def raised?(count)
      return true if new_record?

      before, after = public_send("#{count}_change") || []
      before.to_i < after.to_i
    end
  end
end

# == Schema Information
#
# Table name: collection_items
#
#  id         :bigint           not null, primary key
#  built      :integer          default(0), not null
#  owned      :integer          default(0), not null
#  painted    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  profile_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_collection_items_on_profile_id              (profile_id)
#  index_collection_items_on_user_id_and_profile_id  (user_id,profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (profile_id => profiles.id)
#  fk_rails_...  (user_id => users.id)
#
