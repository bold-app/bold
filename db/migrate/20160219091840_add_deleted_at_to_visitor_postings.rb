class AddDeletedAtToVisitorPostings < ActiveRecord::Migration
  def change
    add_column :visitor_postings, :deleted_at, :timestamp
  end
end
