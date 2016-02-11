class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.uuid :site_id, null: false
      t.integer :taggings_count, default: 0
    end
    execute %{create unique index index_tags_on_site_and_slug ON tags using btree (site_id, slug)}

    create_table :taggings, id: :uuid do |t|
      t.uuid :tag_id, null: false
      t.uuid :taggable_id, null: false, index: true
      t.string :taggable_type, limit: 20, null: false
      t.datetime :created_at, null: false
    end

    add_index :taggings, [:tag_id, :taggable_id], unique: true

    add_foreign_key :tags, :sites, on_delete: :cascade
    add_foreign_key :taggings, :tags, on_delete: :cascade
  end

  def down
    drop_table :taggings
    drop_table :tags
  end
end
