class CreatePermalinks < ActiveRecord::Migration
  def up
    create_table :permalinks, id: :uuid do |t|
      t.string :path, null: false
      t.string :destination_type, null: false
      t.uuid :destination_id, null: false, index: true
      t.uuid :site_id, null: false

      t.timestamps null: false
    end
    add_foreign_key :permalinks, :sites, on_delete: :cascade

    add_column :request_logs, :permalink_id, :uuid
    add_foreign_key :request_logs, :permalinks, on_delete: :nullify

    execute %{create unique index index_permalinks_on_site_and_path ON permalinks using btree (site_id, path)}
  end

  def down
    drop_table :permalinks
  end
end
