class CreateStatsVisits < ActiveRecord::Migration
  def change
    create_table :stats_visits, id: :uuid do |t|
      t.uuid :site_id, null: false
      t.uuid :visitor_id, null: false
      t.string :country_code, limit: 5
      t.string :country_name
      t.boolean :mobile, null: false, default: false

      t.date :date, null: false
      t.timestamp :started_at, null: false
      t.timestamp :ended_at, null: false
    end
    add_foreign_key :stats_visits, :sites, on_delete: :cascade
    add_index :stats_visits, [ :site_id, :date, :mobile ]
  end
end
