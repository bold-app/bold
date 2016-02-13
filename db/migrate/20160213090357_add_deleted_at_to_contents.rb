class AddDeletedAtToContents < ActiveRecord::Migration
  def change
    add_column :contents, :deleted_at, :timestamp
  end
end
