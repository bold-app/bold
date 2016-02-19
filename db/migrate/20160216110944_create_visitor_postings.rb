class CreateVisitorPostings < ActiveRecord::Migration
  def change
    create_table :visitor_postings, id: :uuid do |t|
      t.string :type, null: false, limit: 30
      t.hstore :data, null: false, default: ''
      t.hstore :request, null: false, default: ''
      t.inet :author_ip, null: false

      t.integer :status, null: false, default: 0, index: true

      t.uuid   :content_id, null: false
      t.uuid   :site_id, null: false

      t.timestamps null: false
    end
    add_index :visitor_postings, [:site_id, :type, :content_id]
  end
end
