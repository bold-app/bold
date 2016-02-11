class MementoMigration < ActiveRecord::Migration

  def change
    create_table :memento_sessions do |t|
      t.uuid   :user_id
      t.string :undo_info

      t.timestamps null: false
      t.foreign_key :users, on_delete: :cascade
    end

    create_table :memento_states do |t|
      t.string :action_type
      t.binary :record_data, :limit => 16777215

      t.string :record_type
      t.uuid   :record_id

      t.references :session

      t.timestamps null: false
      t.foreign_key :memento_sessions, column: :session_id, on_delete: :cascade
    end
  end

end
