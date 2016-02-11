class AddDirectoryToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :disk_directory, :string
  end
end
