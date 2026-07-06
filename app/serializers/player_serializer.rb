class PlayerSerializer
  # `secret` reflects the scenario's Secret agenda rule (passed down by GameSerializer). It only
  # affects how much of an *opponent's* agendas a viewer sees — a player always sees all of their own.
  def initialize(player, viewer:, secret: false)
    @player = player
    @viewer = viewer
    @secret = secret
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
      # Hand agendas are open information by default (rulebook: "all players can see other players'
      # Agendas"); the Secret rule keeps them hidden from the opponent until achieved. Either way a
      # player always sees their own hand.
      agendas: hand_visible?(viewing_self) ? hand_agendas : [],
      agenda_history: visible_history(viewing_self)
    }
  end

  private

  def hand_visible?(viewing_self)
    viewing_self || !@secret
  end

  def visible_history(viewing_self)
    events = agenda_history
    return events if viewing_self || !@secret

    # Secret scenario, opponent's view: reveal only resolved events (scored/discarded). Scored
    # agendas are shown because the rule keeps them secret only "until achieved"; discarded ones
    # are shown so the opponent can agree they were unachievable. Dropping `drawn` events also
    # keeps the still-secret hand from leaking through the history.
    events.select { |e| Encounter::Player::RESOLVED_ACTIONS.include?(e[:action]) }
  end

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
