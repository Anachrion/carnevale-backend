class CreateAgendaEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :agenda_events do |t|
      t.references :game_player, null: false, foreign_key: true
      t.references :agenda, null: false, foreign_key: true
      t.references :caused_by_event, foreign_key: { to_table: :agenda_events }
      t.string :action, null: false
      t.string :origin
      t.integer :turn, null: false

      t.timestamps
    end

    add_index :agenda_events, %i[game_player_id agenda_id action], unique: true, name: "index_agenda_events_on_player_agenda_action"
  end
end
