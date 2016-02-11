class CreateSites < ActiveRecord::Migration
  def up
    create_table :sites, id: :uuid do |t|
      t.string :name
      t.string :hostname
      t.string :aliases, array: true, default: []
      t.hstore :config, null: false, default: ''

      t.uuid :homepage_id

      t.timestamps null: false
    end

    execute 'create unique index index_sites_on_hostname ON sites using btree (lower(hostname))'
    execute 'create index index_sites_on_aliases on sites using GIN(aliases)'

    add_foreign_key :contents, :sites, on_delete: :cascade
    add_foreign_key :sites, :contents, column: :homepage_id, on_delete: :nullify
  end

  def down
    drop_table :sites
  end
end
