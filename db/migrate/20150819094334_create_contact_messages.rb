class CreateContactMessages < ActiveRecord::Migration
  def change
    create_table :contact_messages, id: :uuid do |t|
      t.string :subject, null: false
      t.text :body, null: false
      t.string :sender_name, null: false
      t.string :sender_email, null: false
      t.string :receiver_email

      t.uuid :site_id, null: false
      t.uuid :user_id
      t.uuid :content_id

      t.timestamps null: false
    end
    add_foreign_key :contact_messages, :sites, on_delete: :cascade
    add_foreign_key :contact_messages, :users, on_delete: :nullify
    add_foreign_key :contact_messages, :contents, on_delete: :nullify
  end

end
