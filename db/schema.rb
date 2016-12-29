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

ActiveRecord::Schema.define(version: 20160905032813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_trgm"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "assets", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "file",           limit: 500,              null: false
    t.string   "content_type",   limit: 100
    t.hstore   "meta",                       default: {}, null: false
    t.uuid     "site_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "slug",           limit: 500,              null: false
    t.integer  "file_size",                               null: false
    t.string   "disk_directory"
    t.uuid     "creator_id"
    t.index ["site_id", "creator_id"], name: "index_assets_on_site_id_and_creator_id", using: :btree
    t.index ["site_id", "slug"], name: "idx_assets_slugs", unique: true, using: :btree
    t.index ["site_id"], name: "index_assets_on_site_id", using: :btree
  end

  create_table "categories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",        limit: 100
    t.string   "slug",        limit: 100
    t.text     "description"
    t.uuid     "site_id"
    t.uuid     "asset_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["site_id", "slug"], name: "index_categories_on_site_id_and_slug", using: :btree
  end

  create_table "contact_messages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "subject",        null: false
    t.text     "body",           null: false
    t.string   "sender_name",    null: false
    t.string   "sender_email",   null: false
    t.string   "receiver_email"
    t.uuid     "site_id",        null: false
    t.uuid     "user_id"
    t.uuid     "content_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.uuid     "category_id"
    t.datetime "deleted_at"
    t.index ["site_id", "type", "status"], name: "index_contents_on_site_id_and_type_and_status", using: :btree
  end

  create_table "delayed_jobs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "drafts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "content_id"
    t.hstore   "drafted_changes", default: {}, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["content_id"], name: "index_drafts_on_content_id", using: :btree
  end

  create_table "extension_configs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",       limit: 100
    t.string   "type",       limit: 100
    t.hstore   "config",                 default: {}, null: false
    t.uuid     "site_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["name", "site_id"], name: "index_extension_configs_on_name_and_site_id", unique: true, using: :btree
    t.index ["site_id"], name: "index_extension_configs_on_site_id", using: :btree
  end

  create_table "fulltext_indices", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "config"
    t.boolean  "published",       default: false, null: false
    t.string   "searchable_type"
    t.uuid     "searchable_id"
    t.tsvector "tsv"
    t.uuid     "site_id",                         null: false
    t.index ["published"], name: "index_fulltext_indices_on_published", using: :btree
    t.index ["searchable_id", "published"], name: "fulltext_indices_searchable_unique_idx", unique: true, using: :btree
    t.index ["site_id", "searchable_type"], name: "index_fulltext_indices_on_site_id_and_searchable_type", using: :btree
    t.index ["tsv"], name: "fulltext_tsv_idx", using: :gin
  end

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

  create_table "navigations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "url",        null: false
    t.integer  "position"
    t.uuid     "site_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permalinks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "path",             null: false
    t.string   "destination_type", null: false
    t.uuid     "destination_id",   null: false
    t.uuid     "site_id",          null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["site_id", "path"], name: "index_permalinks_on_site_and_path", unique: true, using: :btree
  end

  create_table "redirects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "location",   null: false
    t.boolean  "permanent"
    t.uuid     "site_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_logs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "status",        limit: 2,                                        null: false
    t.boolean  "secure",                                                         null: false
    t.string   "hostname",                                                       null: false
    t.string   "path",                                                           null: false
    t.hstore   "request",                  default: {},                          null: false
    t.hstore   "response",                 default: {},                          null: false
    t.uuid     "site_id",                                                        null: false
    t.uuid     "resource_id"
    t.string   "resource_type", limit: 50
    t.datetime "created_at",                                                     null: false
    t.integer  "device_class",  limit: 2
    t.uuid     "visitor_id",               default: -> { "uuid_generate_v4()" }, null: false
    t.uuid     "permalink_id"
    t.boolean  "processed",                default: false,                       null: false
    t.index ["device_class"], name: "request_logs_device_class_idx", using: :btree
    t.index ["processed", "resource_type"], name: "index_request_logs_on_processed_and_resource_type", using: :btree
    t.index ["site_id", "resource_type", "resource_id"], name: "request_logs_site_id_resource_type_resource_id_idx", using: :btree
  end

  create_table "site_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "site_id",                    null: false
    t.uuid     "user_id",                    null: false
    t.boolean  "manager",    default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["site_id", "user_id"], name: "index_site_users_on_site_id_and_user_id", unique: true, using: :btree
  end

  create_table "sites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "hostname"
    t.string   "aliases",     default: [],              array: true
    t.hstore   "config",      default: {}, null: false
    t.uuid     "homepage_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index "lower((hostname)::text)", name: "index_sites_hostname", unique: true, using: :btree
    t.index ["aliases"], name: "idx_sites_on_aliases", using: :gin
  end

  create_table "stats_pageviews", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "site_id",        null: false
    t.uuid "stats_visit_id", null: false
    t.date "date",           null: false
    t.uuid "content_id",     null: false
    t.uuid "request_log_id", null: false
    t.index ["site_id", "date", "content_id"], name: "index_stats_pageviews_on_site_id_and_date_and_content_id", using: :btree
    t.index ["stats_visit_id"], name: "idx_stats_pageviews_visit_id", using: :btree
  end

  create_table "stats_visits", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "site_id",                                null: false
    t.uuid     "visitor_id",                             null: false
    t.string   "country_code", limit: 5
    t.string   "country_name"
    t.boolean  "mobile",                 default: false, null: false
    t.date     "date",                                   null: false
    t.datetime "started_at",                             null: false
    t.datetime "ended_at",                               null: false
    t.integer  "length"
    t.index ["site_id", "date", "mobile"], name: "index_stats_visits_on_site_id_and_date_and_mobile", using: :btree
  end

  create_table "taggings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "tag_id",                   null: false
    t.uuid     "taggable_id",              null: false
    t.string   "taggable_type", limit: 20, null: false
    t.datetime "created_at",               null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_on_tag_id_and_taggable_type_and_taggable_id", unique: true, using: :btree
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id", using: :btree
  end

  create_table "tags", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string  "name",                       null: false
    t.string  "slug",                       null: false
    t.uuid    "site_id",                    null: false
    t.integer "taggings_count", default: 0
    t.index ["site_id", "slug"], name: "index_tags_on_site_and_slug", unique: true, using: :btree
  end

  create_table "unread_items", force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "item_type"
    t.uuid     "item_id"
    t.uuid     "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "visitor_postings", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",       limit: 30,              null: false
    t.hstore   "data",                  default: {}, null: false
    t.hstore   "request",               default: {}, null: false
    t.inet     "author_ip",                          null: false
    t.integer  "status",                default: 0,  null: false
    t.uuid     "content_id",                         null: false
    t.uuid     "site_id",                            null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
    t.index ["site_id", "type", "content_id"], name: "index_visitor_postings_on_site_id_and_type_and_content_id", using: :btree
    t.index ["status"], name: "index_visitor_postings_on_status", using: :btree
  end

  add_foreign_key "assets", "sites"
  add_foreign_key "assets", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "categories", "assets", on_delete: :nullify
  add_foreign_key "categories", "sites", on_delete: :cascade
  add_foreign_key "contact_messages", "contents", on_delete: :nullify
  add_foreign_key "contact_messages", "sites", on_delete: :cascade
  add_foreign_key "contact_messages", "users", on_delete: :nullify
  add_foreign_key "contents", "categories", on_delete: :nullify
  add_foreign_key "contents", "sites", on_delete: :cascade
  add_foreign_key "contents", "users", column: "author_id", name: "contents_author_id_fkey"
  add_foreign_key "drafts", "contents"
  add_foreign_key "extension_configs", "sites", on_delete: :cascade
  add_foreign_key "fulltext_indices", "sites", name: "site_id_references_sites"
  add_foreign_key "memento_sessions", "users", on_delete: :cascade
  add_foreign_key "memento_states", "memento_sessions", column: "session_id", on_delete: :cascade
  add_foreign_key "navigations", "sites", on_delete: :cascade
  add_foreign_key "permalinks", "sites", on_delete: :cascade
  add_foreign_key "redirects", "sites", on_delete: :cascade
  add_foreign_key "request_logs", "permalinks", name: "request_logs_permalink_id_fkey", on_delete: :nullify
  add_foreign_key "request_logs", "sites", on_delete: :nullify
  add_foreign_key "site_users", "sites", on_delete: :cascade
  add_foreign_key "site_users", "users", on_delete: :cascade
  add_foreign_key "sites", "contents", column: "homepage_id", on_delete: :nullify
  add_foreign_key "stats_pageviews", "contents", on_delete: :cascade
  add_foreign_key "stats_pageviews", "request_logs", on_delete: :nullify
  add_foreign_key "stats_pageviews", "sites", on_delete: :cascade
  add_foreign_key "stats_pageviews", "stats_visits", on_delete: :cascade
  add_foreign_key "stats_visits", "sites", on_delete: :cascade
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "tags", "sites", on_delete: :cascade
  add_foreign_key "users", "users", column: "invited_by_id", on_delete: :nullify
end
