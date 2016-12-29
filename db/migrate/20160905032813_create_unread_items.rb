class CreateUnreadItems < ActiveRecord::Migration[5.0]
  def change
    create_table :unread_items do |t|
      t.uuid :user_id
      t.string :item_type
      t.uuid :item_id
      t.uuid :site_id

      t.timestamps
    end
  end
end
