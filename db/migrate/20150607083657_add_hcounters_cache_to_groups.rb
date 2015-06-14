class AddHcountersCacheToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :hcounters_cache, :hstore
  end
end
