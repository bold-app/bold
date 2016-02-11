class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts, id: :uuid do |t|
      t.uuid :content_id, null: false
      t.hstore :drafted_changes, null: false, default: ''

      t.timestamps null: false
    end
    add_index :drafts, :content_id
    add_foreign_key :drafts, :contents
  end
end
