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

ActiveRecord::Schema.define(version: 20150702102543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "assets", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "file",         limit: 500,              null: false
    t.string   "content_type", limit: 100
    t.hstore   "meta",                     default: {}, null: false
    t.uuid     "site_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "slug",         limit: 500,              null: false
    t.integer  "file_size",                             null: false
  end

  add_index "assets", ["site_id", "slug"], name: "idx_assets_slugs", unique: true, using: :btree
  add_index "assets", ["site_id"], name: "index_assets_on_site_id", using: :btree

  create_table "comments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "body",                                    null: false
    t.string   "author_email",   limit: 100,              null: false
    t.string   "author_name",    limit: 100,              null: false
    t.string   "author_website", limit: 100
    t.integer  "status",                     default: 0,  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.uuid     "site_id"
    t.hstore   "request",                    default: {}, null: false
    t.uuid     "post_id",                                 null: false
    t.inet     "author_ip",                               null: false
    t.datetime "comment_date",                            null: false
  end

  add_index "comments", ["site_id", "post_id"], name: "comments_site_id_post_id_idx", using: :btree
  add_index "comments", ["status"], name: "comments_status_idx", using: :btree
  add_index "comments", ["status"], name: "index_comments_on_status", using: :btree

  create_table "contents", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "type"
    t.string   "title",                 limit: 500
    t.string   "slug",                  limit: 500
    t.string   "template",              limit: 100
    t.text     "body"
    t.text     "teaser"
    t.datetime "post_date"
    t.datetime "last_update"
    t.boolean  "comments_allowed"
    t.integer  "status"
    t.uuid     "site_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.uuid     "author_id"
    t.hstore   "meta",                              default: {}, null: false
    t.hstore   "template_field_values",             default: {}, null: false
  end

  add_index "contents", ["site_id", "slug"], name: "index_contents_on_site_id_and_slug", using: :btree
  add_index "contents", ["site_id"], name: "index_contents_on_site_id", using: :btree
  add_index "contents", ["status"], name: "index_contents_on_status", using: :btree

  create_table "delayed_jobs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "drafts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "content_id"
    t.hstore   "drafted_changes", default: {}, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "drafts", ["content_id"], name: "index_drafts_on_content_id", using: :btree

  create_table "extension_configs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",       limit: 100
    t.string   "type",       limit: 100
    t.hstore   "config",                 default: {}, null: false
    t.uuid     "site_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "extension_configs", ["name", "site_id"], name: "index_extension_configs_on_name_and_site_id", unique: true, using: :btree
  add_index "extension_configs", ["site_id"], name: "index_extension_configs_on_site_id", using: :btree

  create_table "memento_sessions", force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "undo_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memento_states", force: :cascade do |t|
    t.string   "action_type"
    t.binary   "record_data"
    t.string   "record_type"
    t.uuid     "record_id"
    t.integer  "session_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "request_logs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "status",        limit: 2,                                 null: false
    t.boolean  "secure",                                                  null: false
    t.string   "hostname",                                                null: false
    t.string   "path",                                                    null: false
    t.hstore   "request",                  default: {},                   null: false
    t.hstore   "response",                 default: {},                   null: false
    t.uuid     "site_id",                                                 null: false
    t.uuid     "resource_id"
    t.string   "resource_type", limit: 50
    t.datetime "created_at",                                              null: false
    t.integer  "device_class",  limit: 2,                                 null: false
    t.uuid     "visitor_id",               default: "uuid_generate_v4()", null: false
  end

  add_index "request_logs", ["device_class"], name: "request_logs_device_class_idx", using: :btree
  add_index "request_logs", ["site_id", "resource_type", "resource_id"], name: "request_logs_site_id_resource_type_resource_id_idx", using: :btree

  create_table "site_users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "site_id",                    null: false
    t.uuid     "user_id",                    null: false
    t.boolean  "manager",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "site_users", ["site_id", "user_id"], name: "index_site_users_on_site_id_and_user_id", unique: true, using: :btree

  create_table "sites", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "hostname"
    t.text     "aliases",     default: [],              array: true
    t.hstore   "config",      default: {}, null: false
    t.uuid     "homepage_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sites", ["hostname"], name: "index_sites_on_hostname", unique: true, using: :btree

  create_table "taggings", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "tag_id"
    t.uuid     "taggable_id"
    t.string   "taggable_type", limit: 20
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_type", "taggable_id"], name: "taggings_tag_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_type", "taggable_id"], name: "taggings_idx", using: :btree

  create_table "tags", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.uuid    "site_id"
  end

  add_index "tags", ["site_id"], name: "index_tags_on_site_and_name", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "admin",                  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.uuid     "invited_by_id"
    t.hstore   "prefs",                  default: {},    null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  add_foreign_key "assets", "sites"
  add_foreign_key "comments", "contents", column: "post_id", name: "comments_post_id_fkey"
  add_foreign_key "comments", "sites", name: "comments_site_id_fkey", on_delete: :cascade
  add_foreign_key "contents", "sites", on_delete: :cascade
  add_foreign_key "contents", "users", column: "author_id", name: "contents_author_id_fkey"
  add_foreign_key "drafts", "contents"
  add_foreign_key "extension_configs", "sites", on_delete: :cascade
  add_foreign_key "memento_sessions", "users", on_delete: :cascade
  add_foreign_key "memento_states", "memento_sessions", column: "session_id", on_delete: :cascade
  add_foreign_key "request_logs", "sites", on_delete: :nullify
  add_foreign_key "site_users", "sites", on_delete: :cascade
  add_foreign_key "site_users", "users", on_delete: :cascade
  add_foreign_key "sites", "contents", column: "homepage_id", on_delete: :nullify
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "tags", "sites", name: "tags_site_id_fkey"
  add_foreign_key "users", "users", column: "invited_by_id", on_delete: :nullify
end
