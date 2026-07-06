class AddAgendasConfirmedToGamePlayers < ActiveRecord::Migration[8.1]
  # Per-player "I've reviewed my agendas" flag for the agenda_draw phase. Drawing no longer
  # auto-advances the game to deploying; each player confirms once they've read (and optionally
  # mulliganed) their hand, mirroring the `ready` gate on the deployment screen.
  def change
    add_column :game_players, :agendas_confirmed, :boolean, default: false, null: false
  end
end
