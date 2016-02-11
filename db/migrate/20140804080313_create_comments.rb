class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: :uuid do |t|
      t.text   :body, null: false
      t.string :author_email, limit: 100, null: false
      t.string :author_name, limit: 100, null: false
      t.string :author_website, limit: 100
      t.inet   :author_ip, null: false
      t.hstore :request, null: false, default: ''

      t.integer :status, null: false, default: 0

      t.datetime :comment_date, null: false

      t.uuid :post_id, null: false
      t.uuid :site_id, null: false

      t.timestamps null: false
    end
    add_index :comments, [:site_id, :post_id]
    add_index :comments, :status
    add_foreign_key :comments, :sites, on_delete: :cascade
    add_foreign_key :comments, :contents, column: :post_id, on_delete: :cascade
  end
end
