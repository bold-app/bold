class AddLengthToVisits < ActiveRecord::Migration
  def up
    add_column :stats_visits, :length, :integer
    add_index :stats_pageviews, :stats_visit_id
    execute 'update stats_visits set length=(select count(*) from stats_pageviews where stats_visit_id = stats_visits.id)'
  end

  def down
    remove_column :stats_visits, :length
  end
end
