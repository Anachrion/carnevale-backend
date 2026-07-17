class CreateProfileSpellPools < ActiveRecord::Migration[8.1]
  def change
    # One row per "spell pool" a mage profile has (almost always one; Doctor of the Firmament and
    # Seamstress are the exceptions with two). Replaces the old free-text "Mage (X)" / "Expert
    # Sorcerer (X)" / "Discipline (A, B)" regex parsing on Catalog::Profile with structured data that
    # can express every deviation the audit found (CARNEVALEB-47).
    create_table :profile_spell_pools do |t|
      t.references :profile, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      # How many of this pool's eligible disciplines apply simultaneously. 1 for every standard
      # mage; 2 for Doctor of the Firmament (Aetheric Gaze).
      t.integer :of, null: false, default: 1
      # Non-Cantrip spells this pool grants. Meaningless when `unlimited` is true.
      t.integer :slot_count, null: false, default: 0
      # The Mage(X)-only portion of slot_count, i.e. excluding any Expert Sorcerer(Y) bonus rolled
      # into the same pool. Equal to slot_count for every profile with no separate Expert Sorcerer
      # ability. Exists because Apprentice Doctor's Apprenticeship only ever copies the Mage
      # ability, never Expert Sorcerer — a mentor with both (Doctor of the Firmament) still only
      # hands the apprentice the Mage-sized slot count.
      t.integer :mage_slot_count, null: false, default: 0
      # Adventuring Noble's Arcane Totem: every spell of the discipline is known automatically, no
      # picks needed (spell_count above is ignored).
      t.boolean :unlimited, null: false, default: false
      # Whether committing a discipline in this pool grants that discipline's Cantrip. Per-pool, not
      # global — Seamstress's Expert Sorcerer bonus pool grants no extra Cantrip even though her base
      # pool does (Entwined Magics).
      t.boolean :grants_cantrip, null: false, default: true
      # Whether a spell cast from this pool resets each round (the universal rule) or persists for
      # the whole game once cast. False only for Adventuring Noble's pool (Arcane Totem: "once per
      # game").
      t.boolean :resets_each_round, null: false, default: true
      # Apprentice Doctor's Apprenticeship: this pool's eligible disciplines and slot_count aren't
      # static — they're resolved at spell-selection time from whichever mentor entry the player
      # chose (Gang::Entry#mentored_by_entry_id).
      t.boolean :mentor_derived, null: false, default: false
      # Tarot Reader's Minor Arcana: her bonus cantrip-only pool must be a *different* Discipline
      # from whatever her base pool committed to ("1 additional Cantrip... from a different
      # available Discipline") — checked against every other pool on the same profile, not just
      # the first one, so this generalizes to any future profile with the same shape.
      t.boolean :distinct_from_other_pools, null: false, default: false
      # The Special Rule (if any) that explains this pool's deviation from the standard model, so the
      # picker UI can show the real rule text instead of hardcoded per-profile copy. Nullified rather
      # than blocked if that rule is ever deleted from the catalog — the pool's own mechanics don't
      # depend on the rule row existing, only its explanatory text.
      t.references :special_rule, null: true, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end
