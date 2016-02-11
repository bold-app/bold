class CreateStatsPageviews < ActiveRecord::Migration
  def change
    create_table :stats_pageviews, id: :uuid do |t|
      t.uuid :site_id,        null: false
      t.uuid :stats_visit_id, null: false
      t.date :date,           null: false
      t.uuid :content_id,     null: false
      t.uuid :request_log_id, null: false
    end
    add_foreign_key :stats_pageviews, :sites, on_delete: :cascade
    add_foreign_key :stats_pageviews, :stats_visits, on_delete: :cascade
    add_foreign_key :stats_pageviews, :request_logs, on_delete: :nullify
    add_foreign_key :stats_pageviews, :contents, on_delete: :cascade
    add_index :stats_pageviews, [ :site_id, :date, :content_id ]
  end
end
