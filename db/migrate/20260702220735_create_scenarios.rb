class CreateScenarios < ActiveRecord::Migration[8.1]
  def change
    create_table :scenarios do |t|
      t.string :name,              null: false
      t.text   :setup,             null: false, default: ""
      t.text   :primary_objective, null: false, default: ""
      t.json   :agendas,           null: false, default: []
      t.json   :special_rules,     null: false, default: []
      t.string :duration,          null: false, default: ""
      t.json   :deployment_zones,  null: false, default: []
      t.string :illustration

      t.timestamps
    end
  end
end
