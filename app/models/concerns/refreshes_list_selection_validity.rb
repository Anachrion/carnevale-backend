# Recomputes a Gang::List's cached selection validity after any change to a record that can affect
# it (an entry or one of its spells). Each including model reaches the list differently, so it
# supplies `#selection_validity_list`; the after_commit + refresh call itself lives here once
# instead of being copy-pasted onto each model.
module RefreshesListSelectionValidity
  extend ActiveSupport::Concern

  included do
    after_commit :refresh_list_selection_validity, on: %i[create update destroy]
  end

  private

  def refresh_list_selection_validity
    selection_validity_list&.refresh_selection_validity
  end
end
