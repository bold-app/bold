class CreateNavigations < ActiveRecord::Migration
  def change
    create_table :navigations, id: :uuid do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.integer :position
      t.uuid :site_id, null: false

      t.timestamps null: false
    end
    add_foreign_key :navigations, :sites, on_delete: :cascade
  end
end
