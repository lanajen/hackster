class ConvertCountersToHstoreForParts < ActiveRecord::Migration
  def up
    remove_column :parts, :counters_cache
    add_column :parts, :counters_cache, :hstore
  end

  def down
    remove_column :parts, :counters_cache
    add_column :parts, :counters_cache, :text
  end
end
