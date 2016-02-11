class CreateSiteUsers < ActiveRecord::Migration
  def change
    create_table :site_users, id: :uuid do |t|
      t.uuid :site_id, null: false
      t.uuid :user_id, null: false
      t.boolean :manager, default: false, null: false

      t.timestamps null: false
    end

    add_index :site_users, [:site_id, :user_id], unique: true
    add_foreign_key :site_users, :sites, on_delete: :cascade
    add_foreign_key :site_users, :users, on_delete: :cascade
  end
end
