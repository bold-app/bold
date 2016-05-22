class AddCreatedByToAssets < ActiveRecord::Migration[5.0]
  def change
    add_column :assets, :creator_id, :uuid
    add_index :assets, [:site_id, :creator_id]
    add_foreign_key :assets, :users, column: :creator_id, on_delete: :nullify
  end
end
