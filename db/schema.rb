# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_27_170503) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "card_references", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.string "name"
    t.bigint "profile_id"
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_card_references_on_identifier", unique: true
    t.index ["profile_id"], name: "index_card_references_on_profile_id"
  end

  create_table "illustrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "flipped", default: false, null: false
    t.integer "number", default: 1, null: false
    t.integer "offset_x", default: 0, null: false
    t.integer "offset_y", default: 0, null: false
    t.string "path", null: false
    t.bigint "profile_id", null: false
    t.datetime "updated_at", null: false
    t.integer "zoom", default: 100, null: false
    t.index ["profile_id", "number"], name: "index_illustrations_on_profile_id_and_number", unique: true
    t.index ["profile_id"], name: "index_illustrations_on_profile_id"
  end

  create_table "list_entries", force: :cascade do |t|
    t.bigint "card_reference_id", null: false
    t.datetime "created_at", null: false
    t.bigint "list_id", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["card_reference_id"], name: "index_list_entries_on_card_reference_id"
    t.index ["list_id", "card_reference_id"], name: "index_list_entries_on_list_id_and_card_reference_id", unique: true
    t.index ["list_id", "position"], name: "index_list_entries_on_list_id_and_position", unique: true
    t.index ["list_id"], name: "index_list_entries_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "faction", null: false
    t.string "name"
    t.integer "points", default: 100, null: false
    t.datetime "updated_at", null: false
  end

  create_table "profile_special_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "profile_id", null: false
    t.bigint "special_rule_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_profile_special_rules_on_profile_id"
    t.index ["special_rule_id"], name: "index_profile_special_rules_on_special_rule_id"
  end

  create_table "profile_weapons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "profile_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "weapon_id", null: false
    t.index ["profile_id"], name: "index_profile_weapons_on_profile_id"
    t.index ["weapon_id"], name: "index_profile_weapons_on_weapon_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.json "abilities", default: [], null: false
    t.integer "action_points", default: 0, null: false
    t.integer "attack", default: 0, null: false
    t.integer "command_points", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "dexterity", default: 0, null: false
    t.integer "ducats", default: 0, null: false
    t.string "faction", default: "", null: false
    t.json "keywords", default: [], null: false
    t.integer "life_points", default: 0, null: false
    t.integer "mind", default: 0, null: false
    t.integer "movement", default: 0, null: false
    t.string "name", default: "", null: false
    t.integer "protection", default: 0, null: false
    t.integer "size", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "version", default: "2.2.0", null: false
    t.integer "will_points", default: 0, null: false
  end

  create_table "special_rules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "name", null: false
    t.integer "spell_cost"
    t.text "spell_description"
    t.integer "spell_difficulty"
    t.string "spell_name"
    t.datetime "updated_at", null: false
  end

  create_table "weapons", force: :cascade do |t|
    t.json "abilities", default: [], null: false
    t.datetime "created_at", null: false
    t.integer "damage", default: 0, null: false
    t.integer "evasion", default: 0, null: false
    t.string "name", null: false
    t.integer "penetration", default: 0, null: false
    t.integer "range", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "card_references", "profiles"
  add_foreign_key "illustrations", "profiles"
  add_foreign_key "list_entries", "card_references"
  add_foreign_key "list_entries", "lists"
  add_foreign_key "profile_special_rules", "profiles"
  add_foreign_key "profile_special_rules", "special_rules"
  add_foreign_key "profile_weapons", "profiles"
  add_foreign_key "profile_weapons", "weapons"
end
