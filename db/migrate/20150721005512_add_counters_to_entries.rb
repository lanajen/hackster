class AddCountersToEntries < ActiveRecord::Migration
  def change
    add_column :challenge_projects, :counters_cache, :hstore
  end
end
