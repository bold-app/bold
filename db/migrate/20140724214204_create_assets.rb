class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets, id: :uuid do |t|
      t.string :file,  limit: 500, null: false
      t.string :slug,  limit: 500, null: false

      t.string :content_type, limit: 100
      t.integer :file_size, null: false

      t.hstore :meta, null: false, default: ''

      t.uuid :site_id, null: false

      t.timestamps null: false
    end

    add_index :assets, [:site_id, :slug], unique: true
    add_index :assets, :file

    add_foreign_key :assets, :sites, on_delete: :cascade
    add_foreign_key :categories, :assets, on_delete: :nullify
  end
end
