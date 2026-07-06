class GameSerializer
  def initialize(game, viewer:)
    @game = game
    @viewer = viewer
  end

  def as_json
    game = @game
    {
      id: game.id,
      name: game.name,
      join_code: game.join_code,
      status: game.status,
      ducat_limit: game.ducat_limit,
      board_size: game.board_size,
      current_turn: game.current_turn,
      scenario: ScenarioSerializer.new(game.scenario).as_json,
      viewer_visibility: @viewer&.visibility,
      players: game.game_players.map { |gp| PlayerSerializer.new(gp, viewer: @viewer, secret: game.scenario.secret_agendas?).as_json }
    }
  end
end
