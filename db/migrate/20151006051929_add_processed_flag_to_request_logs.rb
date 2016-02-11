class AddProcessedFlagToRequestLogs < ActiveRecord::Migration
  def change
    add_column :request_logs, :processed, :boolean, default: false, null: false
    add_index :request_logs, [:processed, :resource_type]
  end
end
