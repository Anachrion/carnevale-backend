class PlayerSerializer
  def initialize(player, viewer:)
    @player = player
    @viewer = viewer
  end

  def as_json
    player = @player
    viewing_self = @viewer&.id == player.id
    {
      id: player.id,
      user_id: player.user_id,
      username: player.user.username,
      host: player.host,
      list: player.list && ListSummarySerializer.new(player.list).as_json,
      role: player.role,
      ready: player.ready,
      won_role_roll: player.won_role_roll,
      won_deployment_roll: player.won_deployment_roll,
      score: player.score,
      # Drawn agendas and their history are private — only ever revealed to the player who drew them.
      agendas: viewing_self ? hand_agendas : [],
      agenda_history: viewing_self ? agenda_history : []
    }
  end

  private

  def hand_agendas
    Catalog::Agenda.where(id: @player.hand_agenda_ids).map { |a| { id: a.id, name: a.name, description: a.description } }
  end

  def agenda_history
    @player.agenda_events.includes(:agenda).order(:turn, :id).map do |event|
      {
        turn: event.turn,
        action: event.action,
        origin: event.origin,
        caused_by_event_id: event.caused_by_event_id,
        agenda: { id: event.agenda.id, name: event.agenda.name }
      }
    end
  end
end
