# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151022162706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "accounts", force: :cascade do |t|
    t.integer  "plan_id",                   null: false
    t.boolean  "enabled",    default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "accounts", ["plan_id"], name: "index_accounts_on_plan_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "name"
    t.decimal  "cost"
    t.decimal  "file_size_limit"
    t.integer  "scans_per_month"
    t.boolean  "available_for_new_subscriptions", default: true, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "projects", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "account_id",                  null: false
    t.string   "name"
    t.string   "callback_url"
    t.string   "access_key_id"
    t.string   "encrypted_secret_access_key"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "projects", ["account_id"], name: "index_projects_on_account_id", using: :btree

  create_table "scans", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "project_id",                           null: false
    t.string   "url"
    t.string   "key",                                  null: false
    t.boolean  "force",                default: false
    t.integer  "status",               default: 0
    t.string   "result"
    t.string   "md5"
    t.string   "sha1"
    t.string   "sha256"
    t.integer  "file_size",  limit: 8
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "scans", ["md5"], name: "index_scans_on_md5", using: :btree
  add_index "scans", ["project_id"], name: "index_scans_on_project_id", using: :btree

  add_foreign_key "accounts", "plans"
  add_foreign_key "projects", "accounts"
  add_foreign_key "scans", "projects"
end
