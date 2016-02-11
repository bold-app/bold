class CreateFulltextIndices < ActiveRecord::Migration
  def up
    create_table :fulltext_indices, id: :uuid do |t|
      t.string :config

      t.boolean :published, null: false, default: false, index: true
      t.string :searchable_type, index: true
      t.uuid :searchable_id
      t.uuid :site_id, null: false
    end
    execute %{alter table fulltext_indices add column tsv tsvector}
    execute %{create unique index fulltext_indices_searchable_unique_idx on fulltext_indices using btree(searchable_id, published)}
    execute %{create index fulltext_tsv_idx on fulltext_indices using gin(tsv)}
    add_index :fulltext_indices, [:site_id, :searchable_type]
    add_foreign_key :fulltext_indices, :sites, on_delete: :cascade
  end

  def down
    drop_table :fulltext_indices
  end
end
