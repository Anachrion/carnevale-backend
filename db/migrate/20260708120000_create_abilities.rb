class CreateAbilities < ActiveRecord::Migration[8.1]
  def change
    create_table :abilities do |t|
      # "character" (rulebook p44-46) or "weapon" (p47-48) glossary rule.
      t.string :category,    null: false
      # Base name without the "(X)" rating, e.g. "Acrobatic", "Reload".
      t.string :name,        null: false
      t.text   :description, null: false, default: ""

      t.timestamps
    end

    add_index :abilities, [ :category, :name ], unique: true
  end
end
