class CreateAgendas < ActiveRecord::Migration[8.1]
  def change
    create_table :agendas do |t|
      t.string  :name,        null: false
      t.text    :description, null: false, default: ""
      t.string  :first_roll,  null: false
      t.integer :second_roll, null: false

      t.timestamps
    end

    add_index :agendas, [:first_roll, :second_roll], unique: true
  end
end
