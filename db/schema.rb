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

ActiveRecord::Schema[8.1].define(version: 2025_12_05_051815) do
  create_table "journals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "markdown_content"
    t.integer "subproject_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["subproject_id"], name: "index_journals_on_subproject_id"
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "log_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "metadata"
    t.integer "subproject_id"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["subproject_id"], name: "index_log_entries_on_subproject_id"
    t.index ["user_id"], name: "index_log_entries_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_projects_on_name", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.date "expiry"
    t.integer "project_id"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_reports_on_project_id"
  end

  create_table "snapshots", force: :cascade do |t|
    t.json "aggregated_data"
    t.datetime "created_at", null: false
    t.integer "report_id"
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_snapshots_on_report_id"
  end

  create_table "subprojects", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "project_id"
    t.integer "region_id"
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_subprojects_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_subprojects_on_project_id"
    t.index ["region_id"], name: "index_subprojects_on_region_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "role", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest"
    t.string "username"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "journals", "subprojects"
  add_foreign_key "journals", "users"
  add_foreign_key "log_entries", "subprojects"
  add_foreign_key "log_entries", "users"
  add_foreign_key "reports", "projects"
  add_foreign_key "snapshots", "reports"
  add_foreign_key "subprojects", "projects"
  add_foreign_key "subprojects", "regions"
  add_foreign_key "user_roles", "users"
end
