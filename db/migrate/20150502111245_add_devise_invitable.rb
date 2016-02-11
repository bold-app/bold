class AddDeviseInvitable < ActiveRecord::Migration

  def change
    add_column :users, :invitation_token, :string
    add_column :users, :invitation_created_at, :datetime
    add_column :users, :invitation_sent_at, :datetime
    add_column :users, :invitation_accepted_at, :datetime
    add_column :users, :invitation_limit, :integer
    add_column :users, :invited_by_id, :uuid

    # Allow null encrypted_password
    change_column :users, :encrypted_password, :string, :null => true

    add_index :users, :invitation_token, :unique => true
    add_foreign_key :users, :users, column: :invited_by_id, on_delete: :nullify
  end

end
