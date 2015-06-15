class AddHstoreToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :hproperties, :hstore
    add_column :challenges, :hcounters_cache, :hstore
  end
end
