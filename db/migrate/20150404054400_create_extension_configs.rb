class CreateExtensionConfigs < ActiveRecord::Migration
  def change
    create_table :extension_configs, id: :uuid do |t|
      t.string :name, limit: 100
      t.string :type, limit: 100
      t.hstore :config, null: false, default: ''

      t.uuid :site_id

      t.timestamps null: false
    end

    add_index :extension_configs, :site_id
    add_index :extension_configs, [:name, :site_id], unique: true

    add_foreign_key :extension_configs, :sites, on_delete: :cascade
  end
end

