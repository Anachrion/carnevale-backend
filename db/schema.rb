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

ActiveRecord::Schema[8.1].define(version: 2026_07_16_120100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "abilities", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "name"], name: "index_abilities_on_category_and_name", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agenda_events", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "agenda_id", null: false
    t.bigint "caused_by_event_id"
    t.datetime "created_at", null: false
    t.bigint "game_player_id", null: false
    t.string "origin"
    t.integer "turn", null: false
    t.datetime "updated_at", null: false
    t.index ["agenda_id"], name: "index_agenda_events_on_agenda_id"
    t.index ["caused_by_event_id"], name: "index_agenda_events_on_caused_by_event_id"
    t.index ["game_player_id", "agenda_id", "action"], name: "index_agenda_events_on_player_agenda_action", unique: true
    t.index ["game_player_id"], name: "index_agenda_events_on_game_player_id"
  end

  create_table "agendas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "first_roll", null: false
    t.string "name", null: false
    t.integer "second_roll", null: false
    t.datetime "updated_at", null: false
    t.index ["first_roll", "second_roll"], name: "index_agendas_on_first_roll_and_second_roll", unique: true
    t.index ["name"], name: "index_agendas_on_name", unique: true
  end

  create_table "cable_tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_cable_tickets_on_expires_at"
    t.index ["token"], name: "index_cable_tickets_on_token", unique: true
    t.index ["user_id"], name: "index_cable_tickets_on_user_id"
  end

  create_table "card_references", force: :cascade do |t|
    t.string "content_digest"
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.integer "illustration_number", default: 1, null: false
    t.integer "internal_version", default: 1, null: false
    t.string "name"
    t.bigint "profile_id", null: false
    t.string "source_digest"
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_card_references_on_identifier", unique: true
    t.index ["profile_id"], name: "index_card_references_on_profile_id"
  end

  create_table "entry_spells", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "list_entry_id", null: false
    t.bigint "spell_id", null: false
    t.datetime "updated_at", null: false
    t.index ["list_entry_id", "spell_id"], name: "index_entry_spells_on_list_entry_id_and_spell_id", unique: true
    t.index ["list_entry_id"], name: "index_entry_spells_on_list_entry_id"
    t.index ["spell_id"], name: "index_entry_spells_on_spell_id"
  end

  create_table "entry_states", force: :cascade do |t|
    t.json "counters", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "current_command_points", null: false
    t.integer "current_life_points", null: false
    t.integer "current_will_points", null: false
    t.bigint "list_entry_id", null: false
    t.integer "starting_command_points", null: false
    t.integer "starting_life_points", null: false
    t.integer "starting_will_points", null: false
    t.datetime "updated_at", null: false
    t.index ["list_entry_id"], name: "index_entry_states_on_list_entry_id", unique: true
  end

  create_table "equipment", force: :cascade do |t|
    t.integer "cost", null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_players", force: :cascade do |t|
    t.boolean "agendas_confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "current_turn", default: 1, null: false
    t.boolean "finished", default: false, null: false
    t.bigint "game_id", null: false
    t.boolean "host", default: false, null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility", default: "active", null: false
    t.boolean "won_deployment_roll", default: false, null: false
    t.boolean "won_role_roll", default: false, null: false
    t.index ["game_id", "user_id"], name: "index_game_players_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["game_id"], name: "index_game_players_on_game_id_where_won_deployment_roll", unique: true, where: "won_deployment_roll"
    t.index ["game_id"], name: "index_game_players_on_game_id_where_won_role_roll", unique: true, where: "won_role_roll"
    t.index ["user_id"], name: "index_game_players_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "board_size"
    t.datetime "created_at", null: false
    t.integer "ducat_limit", null: false
    t.string "join_code", null: false
    t.string "name", null: false
    t.bigint "scenario_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["join_code"], name: "index_games_on_join_code", unique: true
    t.index ["scenario_id"], name: "index_games_on_scenario_id"
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

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "list_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "entry_id", null: false
    t.string "entry_type", null: false
    t.bigint "list_id", null: false
    t.integer "position", null: false
    t.string "spell_discipline"
    t.boolean "summoned", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["entry_type", "entry_id"], name: "index_list_entries_on_entry_type_and_entry_id"
    t.index ["list_id", "position"], name: "index_list_entries_on_list_id_and_position", unique: true
    t.index ["list_id"], name: "index_list_entries_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "faction", null: false
    t.string "name"
    t.bigint "owner_id", null: false
    t.string "owner_type", null: false
    t.integer "points", default: 100, null: false
    t.json "selection_errors", default: [], null: false
    t.boolean "selection_valid", default: false, null: false
    t.bigint "source_list_id"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_lists_on_owner"
    t.index ["source_list_id"], name: "index_lists_on_source_list_id"
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

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["expires_at"], name: "index_refresh_tokens_on_expires_at"
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "scenarios", force: :cascade do |t|
    t.integer "agenda_count", default: 3, null: false
    t.json "agenda_rules", default: [], null: false
    t.json "agendas", default: [], null: false
    t.boolean "asymmetric", default: false, null: false
    t.datetime "created_at", null: false
    t.json "deployment_zones", default: [], null: false
    t.integer "ducats", default: 0, null: false
    t.string "duration", default: "", null: false
    t.string "illustration"
    t.string "name", null: false
    t.text "primary_objective", default: "", null: false
    t.text "setup", default: "", null: false
    t.json "special_rules", default: [], null: false
    t.integer "turns", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_scenarios_on_name", unique: true
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

  create_table "spells", force: :cascade do |t|
    t.boolean "cantrip", default: false, null: false
    t.integer "cost", null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.integer "difficulty", null: false
    t.string "discipline", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "discipline"], name: "index_spells_on_name_and_discipline", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agenda_events", "agenda_events", column: "caused_by_event_id", on_delete: :nullify
  add_foreign_key "agenda_events", "agendas"
  add_foreign_key "agenda_events", "game_players"
  add_foreign_key "cable_tickets", "users"
  add_foreign_key "card_references", "profiles"
  add_foreign_key "entry_spells", "list_entries"
  add_foreign_key "entry_spells", "spells"
  add_foreign_key "entry_states", "list_entries"
  add_foreign_key "game_players", "games"
  add_foreign_key "game_players", "users"
  add_foreign_key "games", "scenarios"
  add_foreign_key "illustrations", "profiles"
  add_foreign_key "list_entries", "lists"
  add_foreign_key "lists", "lists", column: "source_list_id", on_delete: :nullify
  add_foreign_key "profile_special_rules", "profiles"
  add_foreign_key "profile_special_rules", "special_rules"
  add_foreign_key "profile_weapons", "profiles"
  add_foreign_key "profile_weapons", "weapons"
  add_foreign_key "refresh_tokens", "users"
end
