class CreateRedirects < ActiveRecord::Migration
  def change
    create_table :redirects, id: :uuid do |t|
      t.string :location, null: false
      t.boolean :permanent

      t.uuid :site_id, null: false

      t.timestamps null: false
    end
    add_foreign_key :redirects, :sites, on_delete: :cascade
  end
end
