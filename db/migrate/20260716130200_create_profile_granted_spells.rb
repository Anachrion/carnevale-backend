class CreateProfileGrantedSpells < ActiveRecord::Migration[8.1]
  def change
    # Spells a profile knows automatically, outside the normal pool pick. Two shapes:
    #  - `named_spell`: either a real Catalog::Spell (Galilean Priest's Waves of Force, from a
    #    discipline she has no other access to) or a character-unique spell with no discipline at
    #    all (The Drowned Nun's Dagonite Baptism, Maria Fioritura's Creative Creation) — the latter
    #    stored in the same ad hoc unique_spell_* columns Catalog::SpecialRule already uses for this.
    #  - `all_cantrips`: Blood Crone's Major Arcana (knows all 5 Cantrips regardless of discipline
    #    access) — one row instead of five.
    create_table :profile_granted_spells do |t|
      t.references :profile, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.references :spell, null: true, foreign_key: true
      t.string :unique_spell_name
      t.integer :unique_spell_cost
      t.integer :unique_spell_difficulty
      t.text :unique_spell_description
      t.string :grant_kind, null: false, default: "named_spell"
      # Every currently-known case is additive/free; kept as a real flag rather than assumed, since
      # Maria Fioritura's Creative Creation was ambiguous until confirmed additive.
      t.boolean :consumes_slot, null: false, default: false
      t.boolean :resets_each_round, null: false, default: true
      t.references :special_rule, null: true, foreign_key: { on_delete: :nullify }

      t.timestamps
    end

    add_check_constraint :profile_granted_spells,
      "grant_kind IN ('named_spell', 'all_cantrips')",
      name: "profile_granted_spells_grant_kind_check"
  end
end
