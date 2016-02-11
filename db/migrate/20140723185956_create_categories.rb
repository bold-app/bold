class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, limit: 100
      t.string :slug, limit: 100
      t.text :description
      t.uuid :site_id
      t.uuid :asset_id

      t.timestamps null: false
    end
    add_index :categories, [:site_id, :slug]

    add_foreign_key :categories, :sites, on_delete: :cascade

    add_column :contents, :category_id, :uuid
    add_foreign_key :contents, :categories, on_delete: :nullify
  end
end
