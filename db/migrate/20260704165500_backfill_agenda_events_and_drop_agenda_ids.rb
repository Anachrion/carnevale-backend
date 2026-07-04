class BackfillAgendaEventsAndDropAgendaIds < ActiveRecord::Migration[8.1]
  class GamePlayer < ActiveRecord::Base
    self.table_name = "game_players"
  end

  class AgendaEvent < ActiveRecord::Base
    self.table_name = "agenda_events"
  end

  def up
    GamePlayer.reset_column_information

    GamePlayer.find_each do |gp|
      Array(gp.agenda_ids).each do |agenda_id|
        AgendaEvent.create!(game_player_id: gp.id, agenda_id: agenda_id, action: "drawn", origin: "initial", turn: 1)
      end
    end

    remove_column :game_players, :agenda_ids
  end

  def down
    add_column :game_players, :agenda_ids, :json, default: [], null: false
    GamePlayer.reset_column_information

    AgendaEvent.where(action: "drawn", origin: "initial").find_each do |event|
      gp = GamePlayer.find(event.game_player_id)
      gp.update!(agenda_ids: gp.agenda_ids + [ event.agenda_id ])
    end
  end
end
