class AddMetaToContents < ActiveRecord::Migration
  def change
    add_column :contents, :meta, :hstore, default: '', null: false
  end
end
