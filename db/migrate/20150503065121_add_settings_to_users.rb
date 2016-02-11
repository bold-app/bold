class AddSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prefs, :hstore, default: '', null: false
  end
end
