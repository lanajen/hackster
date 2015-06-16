class AddHstoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hcounters_cache, :hstore
    add_column :users, :hproperties, :hstore
  end
end
