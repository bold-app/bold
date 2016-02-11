class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents, id: :uuid do |t|
      t.string   :type
      t.string   :title, limit: 500
      t.string   :slug, limit: 500
      t.string   :template, limit: 100, index: true
      t.text     :body
      t.text     :teaser
      t.hstore   :template_field_values, null: false, default: ''

      t.datetime :post_date
      t.datetime :last_update

      t.boolean  :comments_allowed
      t.integer  :status, limit: 1

      t.uuid :site_id, null: false, index: true
      t.uuid :author_id, index: true

      t.timestamps null: false
    end
    add_index :contents, [:site_id, :type, :status]

  end

end
