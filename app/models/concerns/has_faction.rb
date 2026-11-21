# SPDX-License-Identifier: AGPL-3.0-or-later

module HasFaction
  extend ActiveSupport::Concern

  FACTIONS = %w[guild rashaar patricians gifted strigoi vatican doctors].freeze

  included do
    enum :faction, FACTIONS.index_with(&:itself)
  end
end
