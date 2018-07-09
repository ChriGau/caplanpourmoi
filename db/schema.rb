# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180709084812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "algo_stats", force: :cascade do |t|
    t.integer  "nb_compute_solutions"
    t.integer  "nb_solutions"
    t.integer  "nb_fail"
    t.float    "go_through_solutions_mean_time_per_slot"
    t.float    "solutions_storing_mean_time"
    t.float    "tree_covered_mean"
    t.float    "total_mean_time"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "attachinary_files", force: :cascade do |t|
    t.string   "attachinariable_type"
    t.integer  "attachinariable_id"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree
  end

  create_table "calcul_solution_v1s", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.text     "slots_array"
    t.text     "slotgroups_array"
    t.text     "information"
    t.integer  "compute_solution_id"
    t.index ["compute_solution_id"], name: "index_calcul_solution_v1s_on_compute_solution_id", using: :btree
  end

  create_table "colors", force: :cascade do |t|
    t.text     "name_fr"
    t.text     "name_eng"
    t.text     "hexadecimal_code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "compute_solutions", force: :cascade do |t|
    t.integer  "status"
    t.integer  "planning_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "nb_solutions"
    t.integer  "nb_optimal_solutions"
    t.integer  "nb_iterations"
    t.integer  "nb_possibilities_theory"
    t.decimal  "calculation_length"
    t.integer  "nb_cuts_within_tree"
    t.integer  "p_nb_slots"
    t.string   "p_nb_hours"
    t.text     "p_nb_hours_roles"
    t.text     "team"
    t.text     "p_list_of_slots_ids"
    t.text     "timestamps_algo"
    t.float    "go_through_solutions_mean_time_per_slot"
    t.float    "solution_storing_mean_time_per_slot"
    t.float    "mean_time_per_slot"
    t.text     "fail_level"
    t.float    "percent_tree_covered"
    t.index ["planning_id"], name: "index_compute_solutions_on_planning_id", using: :btree
  end

  create_table "constraints", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "category"
    t.integer  "status"
    t.index ["user_id"], name: "index_constraints_on_user_id", using: :btree
  end

  create_table "plannings", force: :cascade do |t|
    t.integer  "week_number"
    t.integer  "year"
    t.integer  "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "role_users", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_users_on_role_id", using: :btree
    t.index ["user_id"], name: "index_role_users_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "color_id"
    t.index ["color_id"], name: "index_roles_on_color_id", using: :btree
  end

  create_table "slots", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "planning_id"
    t.integer  "role_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["planning_id"], name: "index_slots_on_planning_id", using: :btree
    t.index ["role_id"], name: "index_slots_on_role_id", using: :btree
  end

  create_table "solution_slots", force: :cascade do |t|
    t.integer "nb_extra_hours"
    t.integer "status"
    t.integer "user_id"
    t.integer "slot_id"
    t.integer "solution_id"
    t.index ["slot_id"], name: "index_solution_slots_on_slot_id", using: :btree
    t.index ["solution_id"], name: "index_solution_slots_on_solution_id", using: :btree
    t.index ["user_id"], name: "index_solution_slots_on_user_id", using: :btree
  end

  create_table "solutions", force: :cascade do |t|
    t.integer  "nb_overlaps"
    t.integer  "nb_extra_hours"
    t.integer  "planning_id"
    t.integer  "compute_solution_id"
    t.integer  "effectivity",                   default: 0
    t.integer  "relevance"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "nb_conflicts"
    t.integer  "nb_under_hours"
    t.integer  "nb_users_six_consec_days_fail"
    t.integer  "nb_users_daily_hours_fail"
    t.integer  "compactness"
    t.integer  "nb_users_in_overtime"
    t.decimal  "conficts_percentage"
    t.decimal  "planning_fitness"
    t.index ["compute_solution_id"], name: "index_solutions_on_compute_solution_id", using: :btree
    t.index ["planning_id"], name: "index_solutions_on_planning_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "planning_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["planning_id"], name: "index_teams_on_planning_id", using: :btree
    t.index ["user_id"], name: "index_teams_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "working_hours"
    t.boolean  "is_owner"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "calcul_solution_v1s", "compute_solutions"
  add_foreign_key "compute_solutions", "plannings"
  add_foreign_key "constraints", "users"
  add_foreign_key "role_users", "roles"
  add_foreign_key "role_users", "users"
  add_foreign_key "roles", "colors"
  add_foreign_key "slots", "plannings"
  add_foreign_key "slots", "roles"
  add_foreign_key "solution_slots", "slots"
  add_foreign_key "solution_slots", "solutions"
  add_foreign_key "solution_slots", "users"
  add_foreign_key "solutions", "compute_solutions"
  add_foreign_key "solutions", "plannings"
  add_foreign_key "teams", "plannings"
  add_foreign_key "teams", "users"
end
