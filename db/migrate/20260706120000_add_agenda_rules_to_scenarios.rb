class AddAgendaRulesToScenarios < ActiveRecord::Migration[8.1]
  def change
    # Structured replacement for parsing the free-text `agendas` array (B-P2-11): `agenda_rules`
    # holds the scenario's agenda special rules (a subset of Catalog::Scenario::AGENDA_RULES) and
    # `agenda_count` the initial hand size. The `agendas` text column stays for human-readable display.
    add_column :scenarios, :agenda_rules, :json, null: false, default: []
    add_column :scenarios, :agenda_count, :integer, null: false, default: 3
  end
end
