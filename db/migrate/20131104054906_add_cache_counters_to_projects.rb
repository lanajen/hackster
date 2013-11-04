class AddCacheCountersToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :counters_cache, :text
    add_column :users, :counters_cache, :text
  end
end
