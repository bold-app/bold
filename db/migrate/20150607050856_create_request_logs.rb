class CreateRequestLogs < ActiveRecord::Migration
  def up
    create_table :request_logs, id: :uuid do |t|
      t.integer :status, limit: 2, null: false

      t.boolean :secure, null: false
      t.string :hostname, null: false
      t.string :path, null: false

      t.hstore :request,  default: '', null: false
      t.hstore :response, default: '', null: false
      t.integer :device_class, null: false, default: 0, limit: 1

      t.uuid   :visitor_id, null: false
      t.uuid   :site_id, null: false
      t.uuid   :resource_id
      t.string :resource_type, limit: 50

      t.datetime :created_at, null: false
    end
    execute 'alter table request_logs alter visitor_id set default uuid_generate_v4()'
    add_foreign_key :request_logs, :sites, column: :site_id, on_delete: :nullify
    add_index :request_logs, [:site_id, :resource_type, :resource_id]
    add_index :request_logs, :device_class
    add_index :request_logs, :visitor_id
  end

  def down
    drop_table :request_logs
  end
end
