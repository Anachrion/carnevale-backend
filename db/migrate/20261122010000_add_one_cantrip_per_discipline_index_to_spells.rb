# A Mage knows its Discipline's one Cantrip (Catalog::Spell.cantrip_for). The model validates it,
# but two concurrent saves could both pass that check; this partial index makes the database hold
# the rule too. Production had exactly one cantrip per discipline when it was added (2026-11-22).
class AddOneCantripPerDisciplineIndexToSpells < ActiveRecord::Migration[8.1]
  def change
    add_index :spells, :discipline, unique: true, where: "cantrip", name: "index_spells_one_cantrip_per_discipline"
  end
end
