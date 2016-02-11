class AllowNullDeviceClass < ActiveRecord::Migration
  def up
    execute 'alter table request_logs alter device_class drop not null'
  end

  def down
    execute 'alter table request_logs alter device_class set not null'
  end
end
