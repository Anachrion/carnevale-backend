class CreateCableTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :cable_tickets do |t|
      t.string :token, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :cable_tickets, :token, unique: true
    add_index :cable_tickets, :expires_at
  end
end
